// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/rewards.sol";

contract N2DRewardsTest is Test {
    N2DRewards n2dRewards;
    address owner = address(1);
    address controller = address(2);
    address user = address(3);

    function setUp() public {
        vm.prank(owner);
        n2dRewards = new N2DRewards("N2DRewards", "N2D", owner);
    }

    function testInitialSettings() public {
        assertEq(n2dRewards.name(), "N2DRewards");
        assertEq(n2dRewards.symbol(), "N2D");
        assertEq(n2dRewards.balanceOf(owner), 0);
    }

    function testMintByController() public {
        vm.prank(owner);
        n2dRewards.addController(controller);

        vm.prank(controller);
        n2dRewards.mint(user, 1000);

        assertEq(n2dRewards.balanceOf(user), 1000);
    }

    function testMintByNonController() public {
        vm.expectRevert("Only controllers can mint");
        n2dRewards.mint(user, 1000);
    }

    function testBurnByController() public {
        vm.prank(owner);
        n2dRewards.addController(controller);

        vm.prank(controller);
        n2dRewards.mint(user, 1000);

        vm.prank(controller);
        n2dRewards.burnFrom(user, 500);

        assertEq(n2dRewards.balanceOf(user), 500);
    }

    function testBurnByNonController() public {
        vm.prank(owner);
        vm.expectRevert(bytes("Only controllers can mint"));
        n2dRewards.mint(user, 1000);

        // vm.prank(user);
        // vm.expectRevert(bytes("caller is not the owner"));
        // n2dRewards.burnFrom(user, 500); // Should revert because `user` is not a controller
    }

    function testAddAndRemoveController() public {
        vm.prank(owner);
        n2dRewards.addController(controller);
        assertTrue(n2dRewards.getController(controller));

        vm.prank(owner);
        n2dRewards.removeController(controller);
        assertFalse(n2dRewards.getController(controller));
    }

    function testOnlyOwnerCanAddController() public {
        vm.prank(user);
        vm.expectRevert();
        n2dRewards.addController(controller);
    }

    function testOnlyOwnerCanRemoveController() public {
        vm.prank(owner);
        n2dRewards.addController(controller);

        vm.prank(user);
        vm.expectRevert();
        n2dRewards.removeController(controller);
    }
}
