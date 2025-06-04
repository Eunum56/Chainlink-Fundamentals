// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {LogToken} from "./LogToken.sol";

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

interface ILogAutomation {
    function checkLog(Log calldata log, bytes memory checkData)
        external
        returns (bool upkeepNeeded, bytes memory performData);

    function performUpkeep(bytes calldata performData) external;
}

struct Log {
    uint256 index; // Index of the log in the block
    uint256 timestamp; // Timestamp of the block containing the log
    bytes32 txHash; // Hash of the transaction containing the log
    uint256 blockNumber; // Number of the block containing the log
    bytes32 blockHash; // Hash of the block containing the log
    address source; // Address of the contract that emitted the log
    bytes32[] topics; // Indexed topics of the log
    bytes data; // Data of the log
}

/**
 * @title TransferAutomation
 * @author Mohammed Muzammil
 * @notice Chainlink Log Automation to reward users when TransferTriggered logs are emitted
 * @dev Per transfer X amount of tokens gets minted to the user.
 */
contract TransferAutomation is ILogAutomation {
    // ERRORS
    error TransferAutomationn__InvalidTokenAddress();

    // STATE VARIABLES
    LogToken private token;

    // EVENTS
    event TokensMinted(address user, uint256 amount);

    // MODIFIERS

    // FUNCTIONS
    /**
     * @notice Should provide correct LogToken address can't change later
     * @param _token LogToken address to set
     */
    constructor(address _token) {
        if (_token == address(0)) {
            revert TransferAutomationn__InvalidTokenAddress();
        }
        token = LogToken(_token);
    }

    // EXTERNAL FUNCTIONS
    /**
     * @notice Checks whether upkeep is needed.
     * @param log The log object from Chainlink Automation.
     * @param - Additional check data (unused).
     * @return upkeepNeeded True if upkeep is needed.
     * @return performData Encoded address of the user.
     */
    function checkLog(Log calldata log, bytes memory /* checkData */ )
        external
        pure
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = true;
        address user = _bytes32ToAddress(log.topics[1]);
        performData = abi.encode(user);
        return (upkeepNeeded, performData);
    }

    /**
     * @notice Performs the upkeep by minting tokens.
     * @param performData Encoded address of the user to reward.
     */
    function performUpkeep(bytes calldata performData) external {
        address user = abi.decode(performData, (address));
        token.mint(user, token.getRewardAmount() * 1e18);
        emit TokensMinted(user, token.getRewardAmount());
    }

    // PUBLIC FUNCTIONS

    // INTERNAL FUNCTIONS
    /**
     * @notice Utility function to convert bytes32 to address
     * @param _address The bytes32 address to convert
     * @return The converted address
     */
    function _bytes32ToAddress(bytes32 _address) internal pure returns (address) {
        return address(uint160(uint256(_address)));
    }

    // PRIVATE FUNCTIONS

    // VIEW AND PURE FUNCTION
    /**
     * @return Retruns LogToken address
     */
    function getLogToken() external view returns (address) {
        return address(token);
    }
}
