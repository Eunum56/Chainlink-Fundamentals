// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";

import {FlexiToken} from "src/CCIP/FlexiToken.sol";
import {Vault} from "src/CCIP/Vault.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RejectingReceiver {
    fallback() external payable {
        revert();
    }
}

contract FlexiTokenUnitTest is Test {
    FlexiToken token;
    Vault vault;
    RejectingReceiver rejectingReceiver;

    uint256 constant INITIAL_REWARDS = 5e18;

    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address user2 = makeAddr("user2");

    // EVENTS
    event Deposit(address indexed user, uint256 amount);
    event Redeem(address indexed user, uint256 amount);

    function setUp() external {
        vm.deal(owner, 5e18);
        vm.startPrank(owner);

        token = new FlexiToken();
        vault = new Vault(token);
        rejectingReceiver = new RejectingReceiver();

        token.grantMintAndBurnRole(address(vault));

        (bool success,) = address(vault).call{value: INITIAL_REWARDS}("");
        require(success);

        vm.stopPrank();
    }

    // REDEEM TESTS
    function testRedeemRevertsIfAmountIsZero() public {
        vm.prank(owner);
        vm.expectRevert(Vault.Vault__AmountShouldBeMoreThanZero.selector);
        vault.redeem(0);
    }

    function testRedeemEmitEvent() public {
        // 1. Deposit
        vm.deal(user, 1e10);
        vm.prank(user);
        vault.deposit{value: 1e10}();
        assertEq(token.balanceOf(user), 1e10);

        // 2. Redeem
        vm.prank(user);
        vm.expectEmit(true, false, false, true);
        emit Redeem(user, 1e10);
        vault.redeem(1e10);

        assertEq(token.balanceOf(user), 0);
        assertEq(address(user).balance, 1e10);
    }

    function testRedeemRevertsIfRedeemFails() public {
        // 1. Deposit
        vm.deal(user, 1e10);
        vm.prank(user);
        vault.deposit{value: 1e10}();
        assertEq(token.balanceOf(user), 1e10);

        // Transfer tokens to contract to get reverted
        vm.prank(user);
        token.transfer(address(rejectingReceiver), 1e10);

        // 2. Redeem with RejectingReceiver contract
        vm.prank(address(rejectingReceiver));
        vm.expectRevert(Vault.Vault__RedeemFailed.selector);
        vault.redeem(1e10);
    }

    // TRANSFER TESTS
    function testTransferUin256MaxAmount() public {
        // 1. Deposit
        vm.deal(user, 1e10);
        vm.prank(user);
        vault.deposit{value: 1e10}();

        assertEq(token.balanceOf(user), 1e10);
        uint256 userBalance = token.balanceOf(user);

        vm.prank(user);
        // 2. Sending Max uint256 amount
        token.transfer(user2, type(uint256).max);

        assertEq(token.balanceOf(user2), userBalance);
    }

    // TRANSFER FROM TESTS
    function testTransferFromUint256MaxAmount() public {
        // 1. Deposit
        vm.deal(user, 1e10);
        vm.prank(user);
        vault.deposit{value: 1e10}();

        assertEq(token.balanceOf(user), 1e10);
        uint256 userBalance = token.balanceOf(user);

        // 2. Give user2 allowance with max uint256
        vm.prank(user);
        IERC20(token).approve(user2, userBalance);

        // 3. Transfer with max uint256
        vm.prank(user2);
        token.transferFrom(user, user2, type(uint256).max);

        assertEq(token.balanceOf(user2), userBalance);
    }

    function testOnlyOwnerCanCallMintAndBurn() public {
        vm.prank(user);
        vm.expectPartialRevert(IAccessControl.AccessControlUnauthorizedAccount.selector);
        token.mint(user, 100);

        vm.prank(user);
        vm.expectPartialRevert(IAccessControl.AccessControlUnauthorizedAccount.selector);
        token.burn(user, 100);
    }

    function testUserLastTimeUpdatedTimestamp() public {
        // 1. Deposit to set user timestamp
        vm.deal(user, 1e10);
        vm.prank(user);
        uint256 firstUserTImestamp = block.timestamp;
        vault.deposit{value: 1e2}();
        assertEq(block.timestamp, firstUserTImestamp);

        // 2. Increase timestamp with vm.warp
        vm.warp(block.timestamp + 1 hours);
        vm.prank(user);
        vault.deposit{value: 1e2}();
        assertEq(token.getUserLastUpdatedTimestamp(user), block.timestamp);
    }
}
