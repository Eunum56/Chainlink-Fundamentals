// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {AutoToken} from "src/Automation/Custom Logic/AutoToken.sol";

contract AutoTokenTest is Test {
    AutoToken token;

    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        vm.prank(owner);
        token = new AutoToken();
    }

    function testAutoTokenConstructorParams() public view {
        assertEq(token.name(), "AutoToken");
        assertEq(token.symbol(), "AT");
        assertEq(token.owner(), owner);
    }

    function testOnlyOwnerCanSetMintingController() public {
        vm.prank(owner);
        vm.expectRevert(AutoToken.AutoToken__InvalidTokenAddress.selector);
        token.setMintingController(address(0));

        vm.prank(owner);
        token.setMintingController(address(1));
        assertEq(token.mintingController(), address(1));
    }

    function testOnlyMintingControllerCanMint() public {
        vm.prank(owner);
        token.setMintingController(address(2));

        vm.prank(user);
        vm.expectRevert(AutoToken.AutoToken__NotMintingController.selector);
        token.mint(user, 10 * 1e18);

        vm.prank(address(2));
        token.mint(owner, 10 * 1e18);
        assertEq(token.balanceOf(owner), 10 * 1e18);
    }
}
