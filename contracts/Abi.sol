// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

interface ERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface ERC721Metadata is ERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface ERC721Enumerable is ERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}

contract Domains is ERC721URIStorage {
    function valid(string calldata name) public pure returns (bool);
    function register(string calldata name) public payable;
    function setRecord(string calldata name, string calldata record) public;
    function getRecord(string calldata name) public view returns (string memory);
    function getAddress(string calldata name) public view returns (address);
    function getAllNames() public view returns (string[] memory);
    function price(string calldata name) public pure returns (uint256);
    function isOwner() public view returns (bool);
    function withdraw() public;
    function owner() external view returns (address);
    function tld() external view returns (string memory);
    function zapToken() external view returns (IERC20);
    function requiredZapBalance() external pure returns (uint256);
    function domains(string calldata name) external view returns (address);
    function records(string calldata name) external view returns (string memory);
    function names(uint256 tokenId) external view returns (string memory);
    function _safeMint(address to, uint256 tokenId) internal virtual override;
    function _setTokenURI(uint256 tokenId, string calldata _tokenURI) internal virtual override;
    function isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override;
    function transferFrom(address from, address to, uint256 tokenId) public virtual override;
    function approve(address to, uint256 tokenId) public virtual override;
    function setApprovalForAll(address operator, bool approved) public virtual override;
    function balanceOf(address owner) public view virtual override returns (uint256);
    function ownerOf(uint256 tokenId) public view virtual override returns (address);
    function getApproved(uint256 tokenId) public view virtual override returns (address);
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool);
    function tokenURI(uint256 tokenId) public
{
