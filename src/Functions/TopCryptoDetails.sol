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

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/V1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/V1_0_0/libraries/FunctionsRequest.sol";

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

    string source = "const trendingResponse = await Functions.makeHttpRequest({"
        "url: `https://api.coingecko.com/api/v3/search/trending`, " "});"
        "if (trendingResponse.error) throw new Error(`Failed to fetch trending tokens`);"
        "const topCoin = trendingResponse.data.coins[0].item;" "const coinId = topCoin.id;"
        "const priceResponse = await Functions.makeHttpRequest({"
        "url: `https://api.coingecko.com/api/v3/coins/${coinId}`," "});"
        "if (priceResponse.error) throw new Error(`Failed to fetch token market data`);"
        "const marketData = priceResponse.data;" "const price = marketData.market_data.current_price.usd;"
        "const platforms = marketData.platforms || {};" "const platformKeys = Object.keys(platforms);"
        "let chain = `N/A`;" "let address = `N/A`;" "if (platformKeys.length > 0) {" "chain = platformKeys[0];"
        "address = platforms[chain];" "}" "const result = {" "name: topCoin.name," "price: price," "chain: chain,"
        "contract: address," "};"
        "return Functions.encodeString(`Name: ${topCoin.name} ,Price: ${price} ,Blockchain: ${chain} ,Contract Address: ${address}`);";

    // EVENTS
    event TopCryptoRequest(address indexed user, bytes32 indexed requestId, uint256 timestamp);
    event FullFillRequest(bytes32 indexed requestId, bytes response, bytes error);

    // MODIFIERS

    // FUNCTIONS
    constructor(uint64 _subId, address _router, bytes32 _donId) FunctionsClient(_router) ConfirmedOwner(msg.sender) {
        i_subscriptionId = _subId;
        i_routerAddress = _router;
        i_donId = _donId;
    }

    // EXTERNAL FUNCTIONS
    function sendRequest() external onlyOwner returns (bytes32) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);

        s_lastRequestId = _sendRequest(req.encodeCBOR(), i_subscriptionId, GAS_LIMIT, i_donId);
        emit TopCryptoRequest(msg.sender, s_lastRequestId, block.timestamp);

        return s_lastRequestId;
    }

    // PUBLIC FUNCTIONS

    // INTERNAL FUNCTIONS
    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (s_lastRequestId != requestId) revert TopCryptoDetails__UnexpectedRequestId();
        if (err.length > 0) revert TopCryptoDetails__ChainlinkFunctionsError();

        s_TopCryptoDetails = string(response);
        emit FullFillRequest(requestId, response, err);
    }
    // PRIVATE FUNCTIONS

    // VIEW AND PURE FUNCTION
    function getRouterAddress() external view returns (address) {
        return i_routerAddress;
    }

    function getDonId() external view returns (bytes32) {
        return i_donId;
    }

    function getTopCryptoDetails() external view returns (string memory) {
        return s_TopCryptoDetails;
    }

    function getLaseRequestId() external view returns (bytes32) {
        return s_lastRequestId;
    }
}
