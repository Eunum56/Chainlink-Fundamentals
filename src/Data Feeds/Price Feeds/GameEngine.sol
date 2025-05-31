// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {GameToken} from "./GameToken.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract GameEngine is ReentrancyGuard, Ownable {
    // ERRORS
    error GameEngine__InvalidAddress(address);
    error GameEngine__NeedToSendETH();
    error GameEngine__InvalidPrice();
    error GameEngine__StalePriceFeed();
    error GameEngine__PriceDataTooOld();
    error GameEngine__InvalidTokenValue();

    // STATE VARIABLES
    GameToken private s_gameToken;
    AggregatorV3Interface private s_priceFeed;
    uint256 private s_tokenValue = 10; // 10 tokens = $1

    // EVENTS
    event TokensPurchased(address indexed user, uint256 ethAmount, uint256 tokensMinted);
    event FundsWithdrawn(address indexed owner, uint256 amount);
    event TokenValueUpdated(uint256 newTokenValue);

    // CONSTRUCTOR
    constructor(address _gameToken, address _priceFeed) Ownable(msg.sender) {
        if (_gameToken == address(0)) revert GameEngine__InvalidAddress(_gameToken);
        if (_priceFeed == address(0)) revert GameEngine__InvalidAddress(_priceFeed);
        s_gameToken = GameToken(_gameToken);
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // EXTERNAL FUNCTIONS
    function buyGameToken() external payable nonReentrant {
        if (msg.value == 0) revert GameEngine__NeedToSendETH();
        p_buyGameToken(msg.sender, msg.value);
    }

    function buyGameToken(address user) external payable nonReentrant {
        if (msg.value == 0) revert GameEngine__NeedToSendETH();
        if (user == address(0)) revert GameEngine__InvalidAddress(user);
        p_buyGameToken(user, msg.value);
    }

    function withdrawFunds() external onlyOwner {
        uint256 amount = address(this).balance;
        emit FundsWithdrawn(owner(), amount);
        Address.sendValue(payable(owner()), amount);
    }

    function setTokenValue(uint256 newTokenValue) external onlyOwner {
        if (newTokenValue == 0) revert GameEngine__InvalidTokenValue();
        s_tokenValue = newTokenValue;
        emit TokenValueUpdated(newTokenValue);
    }

    // PUBLIC FUNCTIONS

    // INTERNAL FUNCTIONS

    // PRIVATE FUNCTIONS
    function p_buyGameToken(address user, uint256 ethAmount) private {
        (uint80 roundId, int256 ethUsdPrice,, uint256 updatedAt, uint80 answeredInRound) = s_priceFeed.latestRoundData();

        if (ethUsdPrice <= 0) revert GameEngine__InvalidPrice();
        if (answeredInRound < roundId) revert GameEngine__StalePriceFeed();
        if (block.timestamp - updatedAt > 1 hours) revert GameEngine__PriceDataTooOld();

        uint8 priceFeedDecimals = s_priceFeed.decimals();
        uint256 usdValue = (ethAmount * uint256(ethUsdPrice)) / (10 ** (18 + priceFeedDecimals));
        uint256 tokenValue = s_tokenValue;
        uint256 tokensToMint = usdValue * tokenValue * 1e18;

        s_gameToken.mint(user, tokensToMint);
        emit TokensPurchased(user, ethAmount, tokensToMint);
    }

    // VIEW AND PURE FUNCTIONS
    function getGameToken() external view returns (address) {
        return address(s_gameToken);
    }

    function getPriceFeed() external view returns (address) {
        return address(s_priceFeed);
    }

    function getTokenValue() external view returns (uint256) {
        return s_tokenValue;
    }
}
