// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {StringUtils} from "./libraries/StringUtils.sol";
// We import another help function
import {Base64} from "./libraries/Base64.sol";

import "hardhat/console.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract Domains is ERC721URIStorage {
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string public tld;
	
  string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none" viewBox="0 0 270 270"><path fill="#fff" d="M0 0h270v270H0z"/><path fill="url(#a)" d="M0 0h270v270H0z"/><g clip-path="url(#b)"></g><defs><linearGradient id="a" x1="0" x2="270" y1="0" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#1D202B"/><stop offset=".37" stop-color="#001358"/><stop offset=".729" stop-color="#0060ff"/><stop offset="1" stop-color="#00c9ff"/></linearGradient><linearGradient id="c" x1="76.363" x2="26.447" y1="72.531" y2="43.712" gradientUnits="userSpaceOnUse"><stop stop-color="#67BC9B"/><stop offset=".2" stop-color="#66B89B"/><stop offset=".4" stop-color="#61AC9C"/><stop offset=".6" stop-color="#5A979E"/><stop offset=".8" stop-color="#507BA0"/><stop offset="1" stop-color="#4358A3"/></linearGradient><linearGradient id="d" x1="7287.09" x2="39978.3" y1="1844.81" y2="1844.81" gradientUnits="userSpaceOnUse"><stop stop-color="#67BC9B"/><stop offset=".2" stop-color="#66B89B"/><stop offset=".4" stop-color="#61AC9C"/><stop offset=".6" stop-color="#5A979E"/><stop offset=".8" stop-color="#507BA0"/><stop offset="1" stop-color="#4358A3"/></linearGradient><clipPath id="b"><path fill="#fff" d="M0 0h80v51H0z" transform="translate(20 23)"/></clipPath><clipPath id="e"><path fill="#fff" d="M0 0h64v56H0z" transform="translate(188 23)"/></clipPath></defs><defs><filter id="f" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><text x="26.5" y="231" font-size="26" fill="#fff" filter="url(#f)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
  
  string svgPartTwo = '</text></svg>';
	
  mapping(string => address) public domains;
  mapping(string => string) public records;
  mapping(uint => string) public names;

IERC20 public zapToken;
uint public constant requiredZapBalance = 10000 * 10**18; // 10,000 ZAP tokens
  address payable public owner;

  constructor(string memory _tld) ERC721("The Zap Name Service", "ZNS") payable {
    owner = payable(msg.sender);
    tld = _tld;
    console.log("%s name service deployed", _tld);
  }

	// This function will give us the price of a domain based on length
	function price(string calldata name) public pure returns (uint256) {
		uint256 len = StringUtils.strlen(name);
		require(len > 0);
		if (len == 3) {
				return 1 * 10**17; // 5 ZAP = 5 000 000 000 000 000 000 (18 decimals). We're going with 0.1 Matic cause the faucets don't give a lot
		} else if (len == 4) {
				return 0.5 * 10**17; // To charge smaller amounts, reduce the decimals. This is 0.05
		} else {
				return 0.2 * 10**17;
		}
	}

  function register(string calldata name) public payable {
    if (domains[name] != address(0)) revert AlreadyRegistered();
    if (!valid(name)) revert InvalidName(name);
    
    require(domains[name] == address(0));

    uint256 _price = price(name);
    require(zapToken.balanceOf(msg.sender) >= requiredZapBalance, "Insufficient ZAP balance");
    require(zapToken.allowance(msg.sender, address(this)) >= _price, "Not enough ZAP allowance");
    require(zapToken.transferFrom(msg.sender, address(this), _price), "ZAP transfer failed");

    require(msg.value >= _price, "Not enough Matic paid");
		
		// Combine the name passed into the function  with the TLD
    string memory _name = string(abi.encodePacked(name, ".", tld));
		// Create the SVG (image) for the NFT with the name
    string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
    uint256 newRecordId = _tokenIds.current();
  	uint256 length = StringUtils.strlen(name);
		string memory strLen = Strings.toString(length);

    console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordId);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            _name,
            '", "description": "A domain on the Zap Name service", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSvg)),
            '","length":"',
            strLen,
            '"}'
          )
        )
      )
    );

    string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));

		console.log("\n--------------------------------------------------------");
	  console.log("Final tokenURI", finalTokenUri);
	  console.log("--------------------------------------------------------\n");

    _safeMint(msg.sender, newRecordId);
    _setTokenURI(newRecordId, finalTokenUri);
    domains[name] = msg.sender;
    names[newRecordId] = name;

    _tokenIds.increment();
  }
	
	// This will give us the domain owners' address
	function getAddress(string calldata name) public view returns (address) {
    return domains[name];
	}

	function setRecord(string calldata name, string calldata record) public {
    // Check that the owner is the transaction sender
    if (msg.sender != domains[name]) revert Unauthorized();
    records[name] = record;
	}

	function getRecord(string calldata name)
			public
			view
			returns (string memory)
	{
			return records[name];
	}

  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  function isOwner() public view returns (bool) {
    return msg.sender == owner;
  }

  function withdraw() public onlyOwner {
    uint amount = address(this).balance;
    
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Failed to withdraw Matic");
  }

  function getAllNames() public view returns (string[] memory) {
    console.log("Getting all names from contract");
    string[] memory allNames = new string[](_tokenIds.current());
    for (uint i = 0; i < _tokenIds.current(); i++) {
      allNames[i] = names[i];
      console.log("Name for token %d is %s", i, allNames[i]);
    }

    return allNames;
  }

  function valid(string calldata name) public pure returns(bool) {
    return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 10;
  }

  error Unauthorized();
  error AlreadyRegistered();
  error InvalidName(string name);
}
