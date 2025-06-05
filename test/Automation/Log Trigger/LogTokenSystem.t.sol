// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {
    DeployLogTokenSystem,
    LogToken,
    TransferAutomation
} from "script/Automation/Log Trigger/DeployLogTokenSystem.s.sol";
import {Log} from "src/Automation/Log Trigger/TransferAutomation.sol";

contract LogTokenSystem is Test {
    LogToken token;
    TransferAutomation automation;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    event TokensMinted(address user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        DeployLogTokenSystem deployer = new DeployLogTokenSystem();
        (token, automation) = deployer.run();

        vm.prank(address(deployer));
        token.transferOwnership(owner);
    }

    // TRANSFER AUTOMATION TESTS
    function testTransferAutomationConstructor() public {
        vm.expectRevert(TransferAutomation.TransferAutomationn__InvalidTokenAddress.selector);
        new TransferAutomation(address(0));

        new TransferAutomation(address(token));
        assertEq(automation.getLogToken(), address(token));
    }

    function testTransferAutomationChecklog() public view {
        bytes32[] memory encodedArray = new bytes32[](3);
        encodedArray[1] = bytes32(uint256(uint160(user)));
        Log memory newLog = Log(0, block.timestamp, "", 1, "", address(0), encodedArray, "");
        (bool upkeepNeeded, bytes memory perfromData) = automation.checkLog(newLog, "");

        assertEq(upkeepNeeded, true);
        address expectedUser = abi.decode(perfromData, (address));

        assertEq(expectedUser, user);
    }

    function testTransferAutomationPerformUpkeep() public {
        assertEq(token.balanceOf(user), 0);

        bytes memory bytesUser = abi.encode(user);
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), user, token.getRewardAmount() * 1e18);
        automation.performUpkeep(bytesUser);

        assertEq(token.balanceOf(user), token.getRewardAmount() * 1e18);
    }

    // LOG TOKEN TESTS
    function testLogTokenConstructor() public {
        vm.prank(owner);
        LogToken newToken = new LogToken(20);

        assertEq(newToken.getRewardAmount(), 20);
        assertEq(newToken.name(), "LogToken");
        assertEq(newToken.symbol(), "LT");
        assertEq(newToken.owner(), owner);
    }

    function testSetTransferAutomation() public {
        vm.prank(owner);
        vm.expectRevert(LogToken.LogToken__InvalidTransferAutomationAddress.selector);
        token.setTransferAutomation(address(0));

        vm.prank(owner);
        token.setTransferAutomation(address(2));
        assertEq(token.getTransferAutomation(), address(2));
    }

    function testLogTokenMint() public {
        vm.prank(address(automation));
        vm.expectRevert(LogToken.LogToken__InvalidAddress.selector);
        token.mint(address(0), 10 * 1e18);

        vm.prank(owner);
        vm.expectRevert(LogToken.LogToken__NotTransferAutomation.selector);
        token.mint(address(owner), 1e18);

        vm.prank(address(automation));
        token.mint(owner, 100 * 1e18);

        assertEq(token.balanceOf(owner), 100 * 1e18);
    }

    function testLogMintWhenTransferAutomationIsNotSet() public {
        LogToken newToken = new LogToken(10);

        vm.prank(address(0));
        vm.expectRevert(LogToken.LogToken__TransferAutomationAddressNotSet.selector);
        newToken.mint(owner, 100 * 1e18);
    }

    function testLogTokenChangeRewardAmount() public {
        assertEq(token.getRewardAmount(), 10);

        vm.prank(owner);
        token.changeRewardAmount(20);

        assertEq(token.getRewardAmount(), 20);
    }
}
