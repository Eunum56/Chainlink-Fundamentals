// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/dev/functions/dev/v1_X/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/functions/dev/libraries/FunctionsRequest.sol";

contract WeatherOracle is FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    // Events
    event WeatherRequestSent(bytes32 indexed requestId);
    event WeatherUpdated(string weatherData);

    // Variables
    string public latestWeather;
    address public owner;
    bytes32 public lastRequestId;

    // Chainlink Functions Config
    uint64 public subscriptionId;
    bytes32 public donID;
    uint32 public gasLimit = 300000;

    constructor(address router, uint64 _subscriptionId, bytes32 _donID) FunctionsClient(router) {
        owner = msg.sender;
        subscriptionId = _subscriptionId;
        donID = _donID;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice Initiates a weather API request via Chainlink Functions
    /// @param source JavaScript source code (bytes format)
    /// @param encryptedSecretsUrls Array of secret reference URLs
    /// @param donHostedSecretsSlot Secrets slot ID
    /// @param donHostedSecretsVersion Secrets version number
    /// @param args Arguments (e.g., city name)
    function requestWeatherData(
        bytes memory source,
        bytes[] memory encryptedSecretsUrls,
        uint8 donHostedSecretsSlot,
        uint64 donHostedSecretsVersion,
        string[] memory args
    ) external onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        req.setSecretsReference(encryptedSecretsUrls, donHostedSecretsSlot, donHostedSecretsVersion);
        req.setArgs(args);

        requestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        lastRequestId = requestId;
        emit WeatherRequestSent(requestId);
    }

    /// @notice Chainlink Functions fulfillment function
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        require(err.length == 0, "Chainlink Functions error occurred");

        latestWeather = string(response);
        emit WeatherUpdated(latestWeather);
    }

    // Admin functions
    function updateGasLimit(uint32 newGasLimit) external onlyOwner {
        gasLimit = newGasLimit;
    }

    function updateSubscriptionId(uint64 newSubId) external onlyOwner {
        subscriptionId = newSubId;
    }

    function updateDonID(bytes32 newDonID) external onlyOwner {
        donID = newDonID;
    }
}
