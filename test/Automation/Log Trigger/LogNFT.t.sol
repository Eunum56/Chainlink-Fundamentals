// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {DeployLogNFT, LogNFT} from "script/Automation/Log Trigger/DeployLogNFT.s.sol";

contract LogNFTTest is Test {
    LogNFT nft;
    address owner = makeAddr("owner");
    address user = makeAddr("user");

    event TransferTriggered(address indexed from, address indexed to, uint256 indexed tokenId);

    function setUp() public {
        DeployLogNFT deployer = new DeployLogNFT();
        nft = deployer.run();
        vm.prank(address(deployer));
        nft.transferOwnership(owner);
    }

    function testLogNFTConstructor() public view {
        assertEq(nft.name(), "LogNFT");
        assertEq(nft.symbol(), "LNFT");
        assertEq(nft.getTokenCounter(), 0);
    }

    function testMintFuncationalityAndReverts() public {
        vm.prank(owner);
        vm.expectRevert(LogNFT.LogNFT__InvalidAddress.selector);
        nft.mint(address(0));

        vm.prank(owner);
        nft.mint(address(1));
        assertEq(1, nft.getTokenCounter());

        for (uint256 i = 0; i <= 998; i++) {
            vm.prank(owner);
            nft.mint(address(1));
        }

        vm.prank(owner);
        vm.expectRevert(LogNFT.LogNFT__MaxSupplyExceeds.selector);
        nft.mint(address(38));
    }

    modifier mintNewNFT() {
        vm.prank(owner);
        nft.mint(owner);
        _;
    }

    function testLogNFTTransferFrom() public mintNewNFT {
        vm.expectEmit(true, true, true, false);
        emit TransferTriggered(owner, user, 0);
        vm.prank(owner);
        nft.transferFrom(owner, user, 0);

        assertEq(nft.balanceOf(owner), 0);
        assertEq(nft.balanceOf(user), 1);
        assertEq(nft.ownerOf(0), user);
    }

    function testSafeTransferWithoutData() public mintNewNFT {
        vm.expectEmit(true, true, true, false);
        emit TransferTriggered(owner, user, 0);
        vm.prank(owner);
        nft.safeTransferFromWithoutData(owner, user, 0);

        assertEq(nft.balanceOf(owner), 0);
        assertEq(nft.balanceOf(user), 1);
        assertEq(nft.ownerOf(0), user);
    }

    function testSafeTransferWithData() public mintNewNFT {
        vm.expectEmit(true, true, true, false);
        emit TransferTriggered(owner, user, 0);
        vm.prank(owner);
        nft.safeTransferFromWithData(owner, user, 0, "");

        assertEq(nft.balanceOf(owner), 0);
        assertEq(nft.balanceOf(user), 1);
        assertEq(nft.ownerOf(0), user);
    }
}
