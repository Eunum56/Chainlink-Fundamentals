// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {GameToken} from "src/Data Feeds/Price Feeds/GameToken.sol";
import {GameEngine} from "src/Data Feeds/Price Feeds/GameEngine.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

contract GameEngineTest is Test {
    GameToken token;
    GameEngine engine;
    MockV3Aggregator mockPriceFeed;

    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address ETHEREUM_SEPOLIA_PRICEFEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    event TokenValueUpdated(uint256 newTokenValue);
    event FundsWithdrawn(address indexed owner, uint256 amount);

    function setUp() public {
        vm.startPrank(owner);

        token = new GameToken();
        mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        engine = new GameEngine(address(token), address(mockPriceFeed));

        token.setGameEngine(address(engine));

        vm.stopPrank();

        vm.deal(owner, 1e18);
    }

    // Constructor test
    function testGameEngineConstructorSetValuesProperly() public {
        assertEq(token.owner(), owner);

        vm.startPrank(owner);

        vm.expectRevert(abi.encodeWithSelector(GameEngine.GameEngine__InvalidAddress.selector, address(0)));
        new GameEngine(address(0), address(mockPriceFeed));

        vm.expectRevert(abi.encodeWithSelector(GameEngine.GameEngine__InvalidAddress.selector, address(0)));
        new GameEngine(address(2), address(0));

        vm.stopPrank();

        assertEq(engine.getGameToken(), address(token));
        assertEq(engine.getPriceFeed(), address(mockPriceFeed));
        assertEq(engine.owner(), owner);
    }

    // Buy GameToken Tests
    function testBuyGameTokenReverts() public {
        vm.prank(user);
        vm.expectRevert(GameEngine.GameEngine__NeedToSendETH.selector);
        engine.buyGameToken();

        vm.prank(user);
        vm.expectRevert(GameEngine.GameEngine__NeedToSendETH.selector);
        engine.buyGameToken(user);

        vm.deal(address(0), 1e5);
        vm.prank(address(0));
        vm.expectRevert(abi.encodeWithSelector(GameEngine.GameEngine__InvalidAddress.selector, address(0)));
        engine.buyGameToken{value: 1e5}(address(0));
    }

    function testBuyGameTokenHappyPath() public {
        uint256 ethAmount = 1 ether;

        vm.deal(user, 10 ether);
        vm.startPrank(user);

        engine.buyGameToken{value: ethAmount}(user);

        // Calculate expected tokens:
        // usdValue = (ethAmount * ethUsdPrice) / 10^(18 + decimals)
        uint256 ethUsdPrice = uint256(mockPriceFeed.latestAnswer()); // e.g., 2000e8
        uint8 decimals = mockPriceFeed.decimals();

        uint256 usdValue = (ethAmount * ethUsdPrice) / (10 ** (18 + decimals));
        uint256 expectedTokens = usdValue * 10 * 1e18; // tokenValue = 10, *1e18 for decimals

        assertEq(token.balanceOf(user), expectedTokens);

        vm.stopPrank();
    }

    function testBuyGameTokenRevertsOnInvalidPrice() public {
        // Set price to 0 (invalid)
        mockPriceFeed.updateAnswer(0);

        uint256 ethAmount = 1 ether;
        vm.prank(owner);
        vm.expectRevert(GameEngine.GameEngine__InvalidPrice.selector);
        engine.buyGameToken{value: ethAmount}(user);
    }

    function testBuyGameTokenRevertsOnStalePrice() public {
        // Manipulate price feed data so answeredInRound < roundId
        mockPriceFeed.updateAnswer(2000e8);
        mockPriceFeed.updateRoundData(2, 2000e8, block.timestamp, block.timestamp);

        // Use vm.mockCall to simulate answeredInRound < roundId in latestRoundData
        vm.mockCall(
            address(mockPriceFeed),
            abi.encodeWithSignature("latestRoundData()"),
            abi.encode(uint80(3), int256(2000e8), uint256(block.timestamp), uint256(block.timestamp), uint80(2))
        );

        uint256 ethAmount = 1 ether;
        vm.prank(owner);
        vm.expectRevert(GameEngine.GameEngine__StalePriceFeed.selector);
        engine.buyGameToken{value: ethAmount}(user);
    }

    function testBuyGameTokenRevertsOnOldPrice() public {
        vm.warp(block.timestamp + 4 hours);
        uint256 oldTimestamp = block.timestamp - 2 hours;
        mockPriceFeed.updateRoundData(1, 2000e8, oldTimestamp, oldTimestamp);

        uint256 ethAmount = 1 ether;

        vm.prank(owner);
        vm.expectRevert(GameEngine.GameEngine__PriceDataTooOld.selector);
        engine.buyGameToken{value: ethAmount}(user);
    }

    // setToken test
    function testSetTokenValueSetsProperly() public {
        vm.prank(owner);
        vm.expectRevert(GameEngine.GameEngine__InvalidTokenValue.selector);
        engine.setTokenValue(0);

        uint256 beforeTokenValue = engine.getTokenValue();
        assertEq(beforeTokenValue, 10);

        vm.prank(owner);
        vm.expectEmit(false, false, false, true);
        emit TokenValueUpdated(5);
        engine.setTokenValue(5);

        uint256 afterTokenValue = engine.getTokenValue();
        assertEq(afterTokenValue, 5);
    }

    // withdraw test
    function testWithdrawSendAmountToOnwer() public {
        uint256 buyingAmount = 1e5;
        vm.prank(owner);
        engine.buyGameToken{value: buyingAmount}();

        assertEq(owner.balance, 1e18 - buyingAmount);

        uint256 beforeContractBalance = address(engine).balance;
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit FundsWithdrawn(owner, beforeContractBalance);
        engine.withdrawFunds();

        uint256 afterContractBalance = address(engine).balance;
        assertEq(afterContractBalance, 0);

        assertEq(owner.balance, 1e18);
    }
}
