// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import "../src/nftStaking.sol";
import "../src/collection.sol";
import "../src/rewards.sol";

contract DeployNFTStaking is Script {
    address initialOwner = address(0); // Replace with the initial owner address

    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy Collection contract
        Collection collection = new Collection(
            "Test Collection",
            "TEST",
            initialOwner
        );

        // Deploy N2DRewards contract
        N2DRewards rewards = new N2DRewards(
            "Reward Token",
            "RTK",
            initialOwner
        );

        // Deploy NFTStaking contract
        NFTStaking nftStaking = new NFTStaking(initialOwner);

        // Add vault to NFTStaking
        nftStaking.addVault(collection, rewards, "Test Vault");

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log contract addresses
        console.log("Collection deployed at:", address(collection));
        console.log("N2DRewards deployed at:", address(rewards));
        console.log("NFTStaking deployed at:", address(nftStaking));
    }
}
