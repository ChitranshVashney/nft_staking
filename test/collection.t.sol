// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/collection.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract CollectionTest is Test {
    Collection collection;
    address owner = address(121);
    address user = address(2);

    function setUp() public {
        collection = new Collection("Test Collection", "TEST", owner);
    }

    function testInitialSettings() public {
        assertEq(collection.name(), "Test Collection");
        assertEq(collection.symbol(), "TEST");
        assertEq(collection.maxSupply(), 100000);
        assertEq(collection.maxMintAmount(), 5);
        assertFalse(collection.paused());
    }

    function testMint() public {
        vm.prank(owner);
        collection.mint(user, 3);

        assertEq(collection.totalSupply(), 3);
        assertEq(collection.balanceOf(user), 3);
        assertEq(collection.ownerOf(1), user);
        assertEq(collection.ownerOf(2), user);
        assertEq(collection.ownerOf(3), user);
    }

    function testMintExceedsMaxMintAmount() public {
        vm.prank(owner);
        vm.expectRevert();
        collection.mint(user, 6); // Should revert as maxMintAmount is 5
    }

    function testMintExceedsMaxSupply() public {
        vm.prank(owner);
        collection.setmaxMintAmount(100001);

        vm.expectRevert();
        collection.mint(user, 100001); // Should revert as maxSupply is 100000
    }

    function testPauseAndMint() public {
        vm.prank(owner);
        collection.pause(true);

        vm.prank(owner);
        vm.expectRevert();
        collection.mint(user, 1); // Should revert as contract is paused
    }

    function testWalletOfOwner() public {
        vm.prank(owner);
        collection.mint(user, 3);

        uint256[] memory tokenIds = collection.walletOfOwner(user);
        assertEq(tokenIds.length, 3);
        assertEq(tokenIds[0], 1);
        assertEq(tokenIds[1], 2);
        assertEq(tokenIds[2], 3);
    }

    function testSetBaseURI() public {
        string memory newBaseURI = "ipfs://new_base_uri/";
        vm.prank(owner);
        collection.setBaseURI(newBaseURI);
        assertEq(collection.baseURI(), newBaseURI);
    }

    function testSetBaseExtension() public {
        string memory newBaseExtension = ".meta";
        vm.prank(owner);
        collection.setBaseExtension(newBaseExtension);
        assertEq(collection.baseExtension(), newBaseExtension);
    }

    function testWithdraw() public {
        // Send some ether to the contract
        vm.deal(address(collection), 1 ether);
        assertEq(address(collection).balance, 1 ether);

        // Withdraw the ether
        vm.prank(owner);
        collection.withdraw();
        assertEq(address(collection).balance, 0);
        assertEq(owner.balance, 1 ether);
    }
}
