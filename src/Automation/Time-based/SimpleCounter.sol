// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

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

/**
 * @title SimpleCounter
 * @author Mohammed Muzammil
 * @notice This contract allows for incrementing a simple counter, intended for demonstration of Chainlink Automation time-based jobs.
 * @dev Designed to work with Chainlink Automation UI to schedule time-based increments via external calls to the `increment()` function.
 */
contract SimpleCounter {
    // ERRORS

    // STATE VARIABLES
    uint256 public count;

    // EVENTS
    event CountAdd(address indexed TriggerAddress, uint256 indexed currentCount);

    // MODIFIERS

    // FUNCTIONS
    constructor() {
        count = 0;
    }

    // External Functions

    /**
     * @notice Increments the counter by 1 every 2 hours.
     * @dev Can be called by Chainlink Automation or any external user.
     * Emits a {CountAdd} event.
     */
    function increment() external {
        ++count;
        emit CountAdd(msg.sender, count);
    }

    // PUBLIC FUNCTIONS

    // INTERNAL FUNCTIONS

    // PRIVATE FUNCTIONS

    // VIEW AND PURE FUNCTION
}
