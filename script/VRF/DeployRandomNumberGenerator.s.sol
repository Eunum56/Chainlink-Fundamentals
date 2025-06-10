// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {VRFHelperConfig} from "./VRFHelperConfig.s.sol";
import {RandomNumberGenerator} from "src/VRF/RandomNumberGenerator.sol";

contract DeployRandomNumberGenerator is Script {
    function run() external {
        VRFHelperConfig helperConfig = new VRFHelperConfig();
        VRFHelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast();
        RandomNumberGenerator rng = new RandomNumberGenerator(config.vrfCoordinator, config.keyHash, config.subId);
        vm.stopBroadcast();
        console.log("RandomNumberGenerator deployed at:", address(rng));
    }
}
