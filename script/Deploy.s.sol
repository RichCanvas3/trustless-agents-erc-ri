// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {IdentityRegistry} from "../src/IdentityRegistryV2.sol";
import {ReputationRegistry} from "../src/ReputationRegistryV2.sol";
import {ValidationRegistry} from "../src/ValidationRegistryV2.sol";

/**
 * @title Deploy
 * @dev Deployment script for ERC-XXXX Trustless Agents Reference Implementation
 * @notice Deploys all three core registry contracts in the correct order
 */
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying ERC-XXXX Trustless Agents Reference Implementation...");
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        
        // Deploy IdentityRegistryV2 first (no dependencies)
        console.log("\n1. Deploying IdentityRegistry...");
        IdentityRegistry identityRegistry = new IdentityRegistry("Trustless Agents Identity", "TAID");
        console.log("IdentityRegistry deployed at:", address(identityRegistry));
        
        // Deploy ReputationRegistryV2 (depends on IdentityRegistryV2)
        console.log("\n2. Deploying ReputationRegistry...");
        ReputationRegistry reputationRegistry = new ReputationRegistry(address(identityRegistry));
        console.log("ReputationRegistry deployed at:", address(reputationRegistry));
        
        // Deploy ValidationRegistryV2 (depends on IdentityRegistryV2)
        console.log("\n3. Deploying ValidationRegistry...");
        ValidationRegistry validationRegistry = new ValidationRegistry(address(identityRegistry));
        console.log("ValidationRegistry deployed at:", address(validationRegistry));
        
        vm.stopBroadcast();
        
        console.log("\n=== Deployment Summary ===");
        console.log("IdentityRegistry:", address(identityRegistry));
        console.log("ReputationRegistry:", address(reputationRegistry));
        console.log("ValidationRegistry:", address(validationRegistry));
    }
}