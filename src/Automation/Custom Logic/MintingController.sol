// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AutoToken} from "./AutoToken.sol";
import {AutomationCompatibleInterface} from
    "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

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
 * @title MintingController for AutoToken
 * @author Mohammed Muzammil
 * @notice Automates periodic minting using Chainlink Automation (Custom Logic)
 * @dev Mints 10 (18 decimals) tokens every 5 hours to the owner address
 */
contract MintingController is AutomationCompatibleInterface {
    // ERRORS
    error MintingController__UpKeepNotNeeded();
    error MintingController__InvalidTokenAddress();

    // STATE VARIABLES
    AutoToken private s_autoToken;
    uint256 private s_interval = 18000; // 5 hours in seconds
    uint256 private s_lastTimeStamp;

    // EVENTS
    event TokensMinted(address indexed to, uint256 amount, uint256 timestamp);

    // MODIFIERS

    // FUNCTIONS
    /**
     * @notice Initializes the lastTimeStamp
     * @param token Token address of the AutoToken contract
     */
    constructor(address token) {
        if (token == address(0)) {
            revert MintingController__InvalidTokenAddress();
        }
        s_autoToken = AutoToken(token);
        s_lastTimeStamp = block.timestamp;
    }

    // EXTERNAL FUNCTIONS
    /**
     * @notice Checks if upKeep needed based on the interval
     * @param - ignored
     * @return upkeepNeeded True if upKeep is needed
     * @return - ignored
     */
    function checkUpkeep(bytes calldata /* checkData */ )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */ )
    {
        upkeepNeeded = (block.timestamp - s_lastTimeStamp) > s_interval;
        return (upkeepNeeded, "");
    }

    /**
     * @notice Performs the upKeep and mints new tokens
     * @param - ignored
     * @dev Mints 10 tokens to the owner address
     */
    function performUpkeep(bytes calldata /* performData */ ) external override {
        if ((block.timestamp - s_lastTimeStamp) > s_interval) {
            s_lastTimeStamp = block.timestamp;
            s_autoToken.mint(s_autoToken.owner(), 10 * 1e18);
            emit TokensMinted(s_autoToken.owner(), 10 * 1e18, block.timestamp);
        } else {
            revert MintingController__UpKeepNotNeeded();
        }
    }

    // PUBLIC FUNCTIONS

    // INTERNAL FUNCTIONS

    // PRIVATE FUNCTIONS

    // VIEW AND PURE FUNCTION
    /**
     * @notice Gets the address of Auto Token Contract
     * @return The address of Auto Token Contract
     */
    function getAutoToken() external view returns (address) {
        return address(s_autoToken);
    }

    /**
     * @notice Gets the interval time
     * @return The interval time (In seconds)
     */
    function getInterval() external view returns (uint256) {
        return s_interval;
    }

    /**
     * @notice Gets the lastTimeStamp
     * @return The lastTimeStamp
     */
    function getLastTimeStamp() external view returns (uint256) {
        return s_lastTimeStamp;
    }
}
