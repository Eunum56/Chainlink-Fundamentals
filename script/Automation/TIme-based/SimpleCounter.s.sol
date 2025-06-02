// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {SimpleCounter} from "src/Automation/Time-based/SimpleCounter.sol";

contract SimpleCounterScript is Script {
    function run() public {
        vm.startBroadcast();
        new SimpleCounter();
        vm.stopBroadcast();
    }
}
