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

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_X/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_X/libraries/FunctionsRequest.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title TopCryptoDetails - Fetches top trending crypto coin names using Chainlink Functions
 * @author Mohammed Muzammil
 * @notice Sends a request to Chainlink Functions to fetch trending coin names from CoinGecko API
 */
contract TopCryptoDetails is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    // ERRORS
    error TopCryptoDetails__UnexpectedRequestId();
    error TopCryptoDetails__ChainlinkFunctionsError();

    // STATE VARIABLES
    uint64 private immutable i_subscriptionId;
    address private immutable i_routerAddress;
    bytes32 private immutable i_donId;

    uint32 private constant GAS_LIMIT = 300000;

    string private s_TopCryptoDetails;
    bytes32 private s_lastRequestId;
    bytes private s_lastError;

    string source = "const count = parseInt(args[0]);"
        "if (isNaN(count) || count <= 0) throw new Error(`Invalid argument. Provide a number between 1 and 10.`);"
        "const trendingResponse = await Functions.makeHttpRequest({"
        "url: `https://api.coingecko.com/api/v3/search/trending`," "});"
        "if (trendingResponse.error) throw new Error(`Failed to fetch trending tokens`);"
        "const coins = trendingResponse.data.coins;" "const limit = Math.min(count, 10, coins.length);"
        "const names = [];" "for (let i = 0; i < limit; i++) {" "names.push(coins[i].item.name);" "}"
        "return Functions.encodeString(names.join(`,`));";

    // EVENTS
    event TopCryptoRequest(address indexed user, bytes32 indexed requestId, uint256 timestamp);
    event FullFillRequest(bytes32 indexed requestId, bytes response, bytes error);

    // MODIFIERS

    // FUNCTIONS
    /**
     * @notice Constructor to initialize the Chainlink Functions client
     * @param _subId Chainlink subscription ID
     * @param _router Router address assossited with chain.id
     * @param _donId Decentralized Oracle Network (DON) ID
     */
    constructor(uint64 _subId, address _router, bytes32 _donId) FunctionsClient(_router) ConfirmedOwner(msg.sender) {
        i_subscriptionId = _subId;
        i_routerAddress = _router;
        i_donId = _donId;
    }

    // EXTERNAL FUNCTIONS
    /**
     * @notice Sends a Chainlink Functions request to fetch top trending coins
     * @param _num Number of Top coins to fetch (Max 10)
     * @return requestId ID of the Chainlink Functions request
     */
    function sendRequest(uint8 _num) external onlyOwner returns (bytes32) {
        FunctionsRequest.Request memory req;

        string[] memory args = new string[](1);
        args[0] = Strings.toString(_num);

        req._initializeRequestForInlineJavaScript(source);
        req._setArgs(args);

        s_lastRequestId = _sendRequest(req._encodeCBOR(), i_subscriptionId, GAS_LIMIT, i_donId);
        emit TopCryptoRequest(msg.sender, s_lastRequestId, block.timestamp);

        return s_lastRequestId;
    }

    // PUBLIC FUNCTIONS

    // INTERNAL FUNCTIONS
    /**
     * @notice Internal function called by Chainlink node to fulfill the request
     * @param requestId The ID of the request
     * @param response response The encoded string response from the off-chain script
     * @param err Error bytes (non-empty if an error occurred)
     */
    function _fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (s_lastRequestId != requestId) revert TopCryptoDetails__UnexpectedRequestId();
        if (err.length > 0) revert TopCryptoDetails__ChainlinkFunctionsError();

        s_TopCryptoDetails = string(response);
        s_lastError = err;
        emit FullFillRequest(requestId, response, err);
    }

    // PRIVATE FUNCTIONS

    // VIEW AND PURE FUNCTION
    /**
     * @notice Returns the router address used for Chainlink Functions
     * @return The router address
     */
    function getRouterAddress() external view returns (address) {
        return i_routerAddress;
    }

    /**
     * @notice Returns the DON ID used for Chainlink Functions
     * @return The DON ID
     */
    function getDonId() external view returns (bytes32) {
        return i_donId;
    }

    /**
     * @notice Returns the last fetched Top Crypto Coins names
     * @return A comma-separated string of top coin names
     */
    function getTopCryptoDetails() external view returns (string memory) {
        return s_TopCryptoDetails;
    }

    /**
     * @notice Returns the last Request ID
     * @return The last Chainlink Functions Request ID
     */
    function getLaseRequestId() external view returns (bytes32) {
        return s_lastRequestId;
    }

    /**
     * @notice Returns the last error message from a failed Chainlink Functions request
     * @return The last error as raw bytes
     */
    function getLastError() external view returns (bytes memory) {
        return s_lastError;
    }
}
