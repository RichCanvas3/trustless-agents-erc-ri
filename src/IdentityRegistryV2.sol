// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.23;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IIdentityRegistry} from "./interfaces/IIdentityRegistryV2.sol"; // reference the interface

contract IdentityRegistry is ERC721, ERC721URIStorage, Ownable, IIdentityRegistry {
    uint256 private _nextId;

    mapping(uint256 => mapping(bytes32 => bytes)) private _metadata;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) Ownable() {}

    // ----------
    // View helpers
    // ----------

    function registryChainId() external view override returns (uint64) {
        return uint64(block.chainid);
    }

    function identityRegistryAddress() external view override returns (address) {
        return address(this);
    }

    function exists(uint256 agentId) public view override returns (bool) {
        return _ownerOf(agentId) != address(0);
    }

    // ----------
    // Minting (admin)
    // ----------

    function mint(address to) external override onlyOwner returns (uint256 agentId) {
        agentId = ++_nextId;
        _safeMint(to, agentId);
    }

    function mintWithURI(address to, string calldata uri)
        external
        override
        onlyOwner
        returns (uint256 agentId)
    {
        agentId = ++_nextId;
        _safeMint(to, agentId);
        _setTokenURI(agentId, uri);
    }

    function setNextId(uint256 nextId_) external override onlyOwner {
        require(nextId_ >= _nextId, "decreasing nextId");
        _nextId = nextId_;
    }

    // ----------
    // Token URI management (controller or operator)
    // ----------

    function setTokenURI(uint256 agentId, string calldata uri) external override {
        _requireControllerOrOperator(agentId);
        _setTokenURI(agentId, uri);
    }

    // ----------
    // On-chain metadata
    // ----------

    function setMetadata(
        uint256 agentId,
        bytes32 key,
        bytes calldata value
    ) external override {
        _requireControllerOrOperator(agentId);
        _metadata[agentId][key] = value;
        emit MetadataSet(agentId, key, value);
    }

    function deleteMetadata(uint256 agentId, bytes32 key) external override {
        _requireControllerOrOperator(agentId);
        delete _metadata[agentId][key];
        emit MetadataDeleted(agentId, key);
    }

    function getMetadata(uint256 agentId, bytes32 key)
        external
        view
        override
        returns (bytes memory)
    {
        return _metadata[agentId][key];
    }

    // ----------
    // Internal
    // ----------

    function _requireControllerOrOperator(uint256 agentId) internal view {
        address owner = ownerOf(agentId);
        require(
            msg.sender == owner ||
                getApproved(agentId) == msg.sender ||
                isApprovedForAll(owner, msg.sender),
            "not controller or operator"
        );
    }

    // ----------
    // Overrides (ERC721 + URIStorage)
    // ----------

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage, IERC721Metadata)
        returns (string memory)
    {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IIdentityRegistry).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
