// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {GameEngine} from "src/Data Feeds/Price Feeds/GameEngine.sol";
import {GameToken} from "src/Data Feeds/Price Feeds/GameToken.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract GameEngineIntegrationTest is Test {
    GameEngine public gameEngine;
    GameToken public gameToken;
    MockV3Aggregator public mockPriceFeed;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);
        mockPriceFeed = new MockV3Aggregator(8, 2000 * 10 ** 8);

        gameToken = new GameToken();

        gameEngine = new GameEngine(address(gameToken), address(mockPriceFeed));

        gameToken.setGameEngine(address(gameEngine));
        vm.stopPrank();
        vm.deal(owner, 10 ether);
    }

    function test_BuyGameToken_MintsTokensCorrectly() public {
        // vm.hoax(user, 10 ether);
        vm.deal(user, 10 ether);
        vm.prank(user);
        gameEngine.buyGameToken{value: 1 ether}();

        // Calculate expected tokens
        uint8 priceFeedDecimals = mockPriceFeed.decimals();
        uint256 ethUsdPrice = uint256(mockPriceFeed.latestAnswer());

        // usdValue = (1 ether * 2000) / 10^(18 + 8)
        uint256 usdValue = (1 ether * ethUsdPrice) / (10 ** (18 + priceFeedDecimals));

        // tokensToMint = usdValue * 10 * 1e18
        uint256 expectedTokens = usdValue * 10 * 1e18;

        uint256 actualTokens = gameToken.balanceOf(user);
        assertEq(actualTokens, expectedTokens, "Token balance mismatch");
    }

    function test_FailsIfPriceIsZero() public {
        // Update price to 0
        mockPriceFeed.updateAnswer(0);

        vm.prank(user);
        vm.deal(user, 10 ether);
        vm.expectRevert(GameEngine.GameEngine__InvalidPrice.selector);
        gameEngine.buyGameToken{value: 1 ether}();
    }

    function test_FailsIfPriceDataTooOld() public {
        vm.warp(block.timestamp + 4 hours);
        // Simulate time passing (2 hours)
        vm.warp(block.timestamp + 2 hours);

        vm.prank(user);
        vm.deal(user, 10 ether);
        vm.expectRevert(GameEngine.GameEngine__PriceDataTooOld.selector);
        gameEngine.buyGameToken{value: 1 ether}();
    }

    function test_FailsIfNoEthSent() public {
        vm.prank(user);
        vm.expectRevert(GameEngine.GameEngine__NeedToSendETH.selector);
        gameEngine.buyGameToken();
    }
}
