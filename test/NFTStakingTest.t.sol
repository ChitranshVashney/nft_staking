// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/nftStaking.sol";
import "../src/collection.sol";
import "../src/rewards.sol";

contract NFTStakingTest is Test {
    NFTStaking nftStaking;
    Collection collection;
    N2DRewards rewards;
    address owner = address(1);
    address user = address(2);

    function setUp() public {
        vm.prank(owner);
        collection = new Collection("Test Collection", "TEST", owner);
        rewards = new N2DRewards("Reward Token", "RTK", owner);
        nftStaking = new NFTStaking(owner);

        vm.prank(owner);
        nftStaking.addVault(collection, rewards, "Test Vault");

        vm.prank(owner);
        rewards.addController(address(nftStaking));

        // Mint some NFTs to the user
        vm.prank(owner);
        collection.mint(user, 5);
    }

    function testInitialSettings() public {
        assertEq(nftStaking.totalStaked(), 0);

        // Access the VaultInfo struct elements correctly
        (, , string memory name) = nftStaking.VaultInfo(0);
        assertEq(name, "Test Vault");
    }

    function testStake() public {
        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 1;
        tokenIds[1] = 2;
        tokenIds[2] = 3;

        vm.prank(user);
        collection.setApprovalForAll(address(nftStaking), true);
        vm.prank(user);
        nftStaking.stake(0, tokenIds);

        assertEq(nftStaking.totalStaked(), 3);
        assertEq(collection.ownerOf(1), address(nftStaking));
        assertEq(collection.ownerOf(2), address(nftStaking));
        assertEq(collection.ownerOf(3), address(nftStaking));
    }

    function testUnstake() public {
        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 1;
        tokenIds[1] = 2;
        tokenIds[2] = 3;

        vm.prank(user);
        collection.setApprovalForAll(address(nftStaking), true);
        vm.prank(user);
        nftStaking.stake(0, tokenIds);

        vm.prank(user);
        nftStaking.unstake(tokenIds, 0);

        assertEq(nftStaking.totalStaked(), 0);
        assertEq(collection.ownerOf(1), user);
        assertEq(collection.ownerOf(2), user);
        assertEq(collection.ownerOf(3), user);
    }

    function testClaimRewards() public {
        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 1;
        tokenIds[1] = 2;
        tokenIds[2] = 3;

        vm.prank(user);
        collection.setApprovalForAll(address(nftStaking), true);
        vm.prank(user);
        nftStaking.stake(0, tokenIds);

        // Simulate time passing
        vm.warp(block.timestamp + 1 days);

        vm.prank(user);
        nftStaking.claim(tokenIds, 0);

        assertEq(rewards.balanceOf(user), 30000 ether);
    }

    function testBalanceOf() public {
        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 1;
        tokenIds[1] = 2;
        tokenIds[2] = 3;

        vm.prank(user);
        collection.setApprovalForAll(address(nftStaking), true);
        vm.prank(user);
        nftStaking.stake(0, tokenIds);

        assertEq(nftStaking.balanceOf(user, 0), 3);
    }

    function testTokensOfOwner() public {
        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 1;
        tokenIds[1] = 2;
        tokenIds[2] = 3;

        vm.prank(user);
        collection.setApprovalForAll(address(nftStaking), true);
        vm.prank(user);
        nftStaking.stake(0, tokenIds);

        uint256[] memory ownerTokens = nftStaking.tokensOfOwner(user, 0);
        assertEq(ownerTokens.length, 3);
        assertEq(ownerTokens[0], 1);
        assertEq(ownerTokens[1], 2);
        assertEq(ownerTokens[2], 3);
    }
}
