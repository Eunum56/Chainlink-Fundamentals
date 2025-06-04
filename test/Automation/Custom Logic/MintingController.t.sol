// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {MintingController} from "src/Automation/Custom Logic/MintingController.sol";
import {AutoToken} from "src/Automation/Custom Logic/AutoToken.sol";

contract MintingControllerTest is Test {
    MintingController controller;
    AutoToken token;

    uint256 deploymentTimeStamp;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);

        token = new AutoToken();

        controller = new MintingController(address(token));

        token.setMintingController(address(controller));

        deploymentTimeStamp = block.timestamp;

        vm.stopPrank();
    }

    function testMintingControllerConstructorParams() public {
        vm.expectRevert(MintingController.MintingController__InvalidTokenAddress.selector);
        new MintingController(address(0));

        assertEq(controller.getAutoToken(), address(token));
        assertEq(controller.getLastTimeStamp(), deploymentTimeStamp);
    }

    function testCheckUpKeepNeeded() public {
        (bool upKeepNeeded,) = controller.checkUpkeep("");
        assertEq(false, upKeepNeeded);

        vm.warp(block.timestamp + controller.getInterval() + 1);

        (bool upKeepNeeded2,) = controller.checkUpkeep("");
        assertEq(true, upKeepNeeded2);
    }

    function testPerformUpKeepReverts() public {
        vm.expectRevert(MintingController.MintingController__UpKeepNotNeeded.selector);
        controller.performUpkeep("");
    }

    function testPerfromUpKeepMintsTheTokens() public {
        vm.warp(block.timestamp + controller.getInterval() + 1);
        vm.prank(owner);
        controller.performUpkeep("");

        assertEq(deploymentTimeStamp + controller.getInterval() + 1, block.timestamp);
        assertEq(token.balanceOf(owner), 10 * 1e18);
    }
}
