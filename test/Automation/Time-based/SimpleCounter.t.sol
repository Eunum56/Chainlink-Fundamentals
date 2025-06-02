// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {SimpleCounter} from "src/Automation/Time-based/SimpleCounter.sol";

contract SimpleCounterTest is Test {
    SimpleCounter simpleCounter;

    address owner = makeAddr("owner");

    event CountAdd(address indexed TriggerAddress, uint256 indexed currentCount);

    function setUp() public {
        vm.prank(owner);
        simpleCounter = new SimpleCounter();
    }

    function testIncrement() public {
        assertEq(simpleCounter.count(), 0);

        vm.expectEmit(true, true, false, false);
        emit CountAdd(owner, simpleCounter.count() + 1);
        vm.prank(owner);
        simpleCounter.increment();

        assertEq(simpleCounter.count(), 1);
    }
}
