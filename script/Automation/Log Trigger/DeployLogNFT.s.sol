// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {LogNFT} from "src/Automation/Log Trigger/LogNFT.sol";

contract DeployLogNFT is Script {
    function run() public returns (LogNFT) {
        if(block.chainid == 31337) {
            LogNFT logNFT = new LogNFT();
            return logNFT;
        } else {
            string memory privatekeyString = vm.envString("PRIVATE_KEY");
            uint256 private_key = vm.parseUint(string(abi.encodePacked("0x", privatekeyString)));
            vm.startBroadcast(private_key);
            LogNFT logNFT = new LogNFT();
            vm.stopBroadcast();
            return logNFT;
        }
    }
}