// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {FlexiToken} from "./FlexiToken.sol";

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// Type declarations
// errors
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

contract Vault {
    // ERRORS
    error Vault__RedeemFailed();
    error Vault__AmountShouldBeMoreThanZero();

    // STATE VARIABLES
    FlexiToken immutable i_flexiToken;

    // EVENTS
    event Deposit(address indexed user, uint256 amount);
    event Redeem(address indexed user, uint256 amount);

    // MODIFIERS

    // FUNCTIONS
    constructor(FlexiToken _flexiToken) {
        i_flexiToken = _flexiToken;
    }

    receive() external payable {}

    // EXTERNAL FUNCTIONS
    function deposit() external payable {
        i_flexiToken.mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function redeem(uint256 _amount) external {
        if(_amount <= 0) {
            revert Vault__AmountShouldBeMoreThanZero();
        }

        // 1. Burn the tokens and send the equalent amount ETH back to the user
        i_flexiToken.burn(msg.sender, _amount);

        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }

        emit Redeem(msg.sender, _amount);
    }

    // PUBLIC FUNCTIONS

    // INTERNAL FUNCTIONS

    // PRIVATE FUNCTIONS

    // VIEW AND PURE FUNCTION
    function getFlexiToken() external view returns (address) {
        return address(i_flexiToken);
    }
}
