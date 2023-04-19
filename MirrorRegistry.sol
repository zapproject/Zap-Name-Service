pragma solidity ^0.8.0;

import "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import "@ensdomains/ens-contracts/contracts/resolvers/ResolverBase.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ZapRegistrar is SubdomainRegistrar {
    ENS public ens;

    constructor(ENS _ens) {
        ens = _ens;
    }

    function createSubdomain(string memory _subdomain) public {
        bytes32 node = keccak256(abi.encodePacked("zap.eth", keccak256(abi.encodePacked(_subdomain))));
        ens.setSubnodeOwner(bytes32(0), keccak256("zap"), address(this));
        ens.setResolver(node, resolver);
        ens.setOwner(node, msg.sender);
    }
}

contract ZapResolver is ResolverBase, ContentHashResolver {
    mapping(bytes32 => bytes) public contenthash;

    function setContenthash(bytes32 _node, bytes calldata _hash) external override only_owner(_node) {
        contenthash[_node] = _hash;
        emit ContenthashChanged(_node, _hash);
    }
}

contract ZapMirrorNFT is ERC721 {
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function mintMirroredNFT(string memory _subdomain, string memory _metadata) public {
        bytes32 node = keccak256(abi.encodePacked("zap.eth", keccak256(abi.encodePacked(_subdomain))));
        bytes32 hash = keccak256(bytes(_metadata));
        contenthashResolver.setContenthash(node, abi.encodePacked(hash));
        _mint(msg.sender, uint256(node));
    }
}
