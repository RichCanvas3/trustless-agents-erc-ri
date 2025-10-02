// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.23;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/// @title IIdentityRegistry (ERC-8004 reference)
/// @notice ERC-721-based agent identity registry + URIStorage + extra metadata
/// @dev agentId == ERC-721 tokenId
interface IIdentityRegistry is IERC165, IERC721, IERC721Metadata {
    // -----------------
    // Events (custom)
    // -----------------

    /// @notice Emitted when on-chain metadata is set for an agent
    event MetadataSet(uint256 indexed agentId, bytes32 indexed key, bytes value);

    /// @notice Emitted when on-chain metadata is deleted for an agent
    event MetadataDeleted(uint256 indexed agentId, bytes32 indexed key);

    // -----------------
    // View helpers
    // -----------------

    /// @notice Returns the EVM chainId this registry is deployed on
    function registryChainId() external view returns (uint64);

    /// @notice Returns this registry's address (for convenience in clients)
    function identityRegistryAddress() external view returns (address);

    /// @notice Returns true if the token (agent) exists
    function exists(uint256 agentId) external view returns (bool);

    // -----------------
    // Minting (admin)
    // -----------------

    /// @notice Mint a new agent NFT to `to` with auto-incremented id
    /// @return agentId The newly minted agent id (tokenId)
    function mint(address to) external returns (uint256 agentId);

    /// @notice Mint a new agent NFT to `to` and set initial tokenURI
    /// @return agentId The newly minted agent id (tokenId)
    function mintWithURI(address to, string calldata uri) external returns (uint256 agentId);

    /// @notice (Optional) Set the next auto-increment id (must not decrease)
    function setNextId(uint256 nextId_) external;

    // -----------------
    // Token URI management (controller or operator)
    // -----------------

    /// @notice Update tokenURI; MUST point to the agent registration file (ipfs:// or https://)
    function setTokenURI(uint256 agentId, string calldata uri) external;

    // -----------------
    // On-chain metadata (optional extras)
    // -----------------

    /// @notice Set opaque metadata (key => bytes) for an agent
    function setMetadata(uint256 agentId, bytes32 key, bytes calldata value) external;

    /// @notice Delete a metadata key for an agent
    function deleteMetadata(uint256 agentId, bytes32 key) external;

    /// @notice Read a metadata value; empty bytes means not set
    function getMetadata(uint256 agentId, bytes32 key) external view returns (bytes memory);
}
