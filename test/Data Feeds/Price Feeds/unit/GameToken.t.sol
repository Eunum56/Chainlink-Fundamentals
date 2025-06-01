// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {GameToken} from "src/Data Feeds/Price Feeds/GameToken.sol";

contract GameTokenTest is Test {
    address owner = makeAddr("owner");
    address user = makeAddr("user");

    GameToken gameToken;

    function setUp() public {
        vm.prank(owner);
        gameToken = new GameToken();
    }

    function testGameTokenConstructorSetValuesProperly() public view {
        string memory name = "Game Token";
        string memory symbol = "GT";

        assertEq(gameToken.owner(), owner);
        assertEq(gameToken.name(), name);
        assertEq(gameToken.symbol(), symbol);
    }

    function testSetEngineSetsTheValueProper() public {
        vm.prank(owner);
        gameToken.setGameEngine(address(1));
        assertEq(gameToken.gameEngine(), address(1));

        vm.prank(owner);
        vm.expectRevert(GameToken.GameToken__InvalidGameEngineAddress.selector);
        gameToken.setGameEngine(address(0));
    }

    function testOnlyGameEngineCanCallMint() public {
        vm.prank(owner);
        gameToken.setGameEngine(address(2));

        vm.prank(address(1));
        vm.expectRevert(GameToken.GameToken__NotGameEngine.selector);
        gameToken.mint(user, 1e5);

        assertEq(gameToken.balanceOf(user), 0);

        vm.prank(address(2));
        gameToken.mint(user, 1e5);

        assertEq(gameToken.balanceOf(user), 1e5);
    }

    function testOnlyGameEngineCanCallBurn() public {
        vm.prank(owner);
        gameToken.setGameEngine(address(2));

        vm.prank(address(1));
        vm.expectRevert(GameToken.GameToken__NotGameEngine.selector);
        gameToken.burn(user, 1e5);

        assertEq(gameToken.balanceOf(user), 0);

        vm.prank(address(2));
        gameToken.mint(user, 1e5);

        assertEq(gameToken.balanceOf(user), 1e5);

        vm.prank(address(2));
        gameToken.burn(user, 1e5);

        assertEq(gameToken.balanceOf(user), 0);
    }
}
