// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";

import {FlexiToken} from "src/CCIP/FlexiToken.sol";
import {Vault} from "src/CCIP/Vault.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlexiTokenFuzzTest is Test {
    FlexiToken token;
    Vault vault;

    uint256 constant INITIAL_REWARDS = 5e18;

    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address user2 = makeAddr("user2");

    function setUp() public {
        vm.startPrank(owner);
        vm.deal(owner, 5e18);

        token = new FlexiToken();
        vault = new Vault(token);

        token.grantMintAndBurnRole(address(vault));
        (bool success,) = address(vault).call{value: INITIAL_REWARDS}("");
        require(success);

        vm.stopPrank();
    }

    // DEPOSIT TESTS
    function testDepositLinear(uint256 amount) public {
        amount = bound(amount, 1e5, type(uint96).max);
        // 1. deposit
        vm.startPrank(user);
        vm.deal(user, amount);
        vault.deposit{value: amount}();

        // 2. check our rebase token balance
        uint256 startingBalance = token.balanceOf(user);
        assertEq(startingBalance, amount);

        // 3. warp the time and check the balance again
        vm.warp(block.timestamp + 1 hours);
        uint256 middleBalance = token.balanceOf(user);
        assertGt(middleBalance, startingBalance);

        // 4. warp the time again by the same amount and check the balance again
        vm.warp(block.timestamp + 1 hours);
        uint256 endingBalance = token.balanceOf(user);
        assertGt(endingBalance, middleBalance);

        assertApproxEqAbs(endingBalance - middleBalance, middleBalance - startingBalance, 1);

        vm.stopPrank();
    }

    // REDEEM TESTS
    function testRedeemStraightAway(uint256 amount) public {
        amount = bound(amount, 1e5, type(uint96).max);
        // 1. Deposit
        vm.startPrank(user);
        vm.deal(user, amount);
        vault.deposit{value: amount}();
        assertEq(token.balanceOf(user), amount);

        // 2. Redeem
        vault.redeem(amount);
        assertEq(token.balanceOf(user), 0);
        assertEq(address(user).balance, amount);
        vm.stopPrank();
    }

    // TRANSFER TESTS
    function testTransfer(uint256 amount, uint256 amountToSend) public {
        amount = bound(amount, 1e10, type(uint96).max);
        amountToSend = bound(amountToSend, 1e5, amount - 1e5);

        // 1. Deposit
        vm.deal(user, amount);
        vm.prank(user);
        vault.deposit{value: amount}();

        uint256 userBalance = token.balanceOf(user);
        uint256 user2Balance = token.balanceOf(user2);

        assertEq(userBalance, amount);
        assertEq(user2Balance, 0);

        // Owner reduces the interest rate.
        vm.prank(owner);
        token.setInterestRate(4e10);

        // Transfer
        vm.prank(user);
        token.transfer(user2, amountToSend);

        uint256 userBalanceAfterAmountSend = token.balanceOf(user);
        uint256 user2BalanceAfterAmountReceived = token.balanceOf(user2);

        assertEq(userBalanceAfterAmountSend, userBalance - amountToSend);
        assertEq(user2BalanceAfterAmountReceived, amountToSend);

        // Check the user interest rate has been inherited (5e10 not 4w10)
        assertEq(token.getUserInterestRate(user), 5e10);
        assertEq(token.getUserInterestRate(user2), 5e10);
    }

    // TRANSFER FROM TESTS
    function testTransferFrom(uint256 amount, uint256 amountToSend) public {
        amount = bound(amount, 1e10, type(uint96).max);
        amountToSend = bound(amountToSend, 1e5, amount - 1e5);

        // 1. Deposit
        vm.deal(user, amount);
        vm.prank(user);
        vault.deposit{value: amount}();

        uint256 userBalance = token.balanceOf(user);
        uint256 user2Balance = token.balanceOf(user2);

        assertEq(userBalance, amount);
        assertEq(user2Balance, 0);

        // Owner reduces the interest rate
        vm.prank(owner);
        token.setInterestRate(4e10);

        // 2. Give user2 Allowance
        vm.prank(user);
        IERC20(token).approve(user2, amountToSend);

        // 3. Transfer
        vm.prank(user2);
        token.transferFrom(user, user2, amountToSend);

        uint256 userBalanceAfterTransfer = token.balanceOf(user);
        uint256 user2BalanceAfterAmountReceived = token.balanceOf(user2);

        assertEq(userBalanceAfterTransfer, userBalance - amountToSend);
        assertEq(user2BalanceAfterAmountReceived, amountToSend);

        // 4. Check the interest rate inherited (5e10 not 4e10)
        assertEq(token.getUserInterestRate(user), 5e10);
        assertEq(token.getUserInterestRate(user2), 5e10);
    }

    function testOnlyOwnerCanSetInterestRate(uint256 newInterestRate) public {
        vm.prank(user);
        vm.expectPartialRevert(Ownable.OwnableUnauthorizedAccount.selector);
        token.setInterestRate(newInterestRate);
    }

    function testPrincipleBalance(uint256 amount) public {
        amount = bound(amount, 1e5, type(uint96).max);
        vm.deal(user, amount);
        vm.prank(user);
        vault.deposit{value: amount}();

        assertEq(token.getPrincipleBalance(user), amount);

        vm.warp(block.timestamp + 1 hours);
        assertEq(token.getPrincipleBalance(user), amount);
    }

    function testInterestRateCanOnlyDecrease(uint256 newInterestRate) public {
        uint256 initialInterestRate = token.getInterestRate();
        newInterestRate = bound(newInterestRate, initialInterestRate + 1, type(uint96).max);

        vm.prank(owner);
        vm.expectPartialRevert(FlexiToken.FlexiToken__InterestRateCanOnlyDecrease.selector);
        token.setInterestRate(newInterestRate);

        assertEq(token.getInterestRate(), initialInterestRate);
    }
}
