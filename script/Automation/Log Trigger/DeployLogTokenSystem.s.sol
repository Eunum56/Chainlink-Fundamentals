// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {LogToken} from "src/Automation/Log Trigger/LogToken.sol";
import {TransferAutomation} from "src/Automation/Log Trigger/TransferAutomation.sol";

contract DeployLogTokenSystem is Script {
    function run() public returns (LogToken, TransferAutomation) {
        if(block.chainid == 31337) {
            LogToken token = new LogToken(10);
            TransferAutomation automation = new TransferAutomation(address(token));

            token.setTransferAutomation(address(automation));

            return (token, automation);
        } else {
            string memory privatekeyString = vm.envString("PRIVATE_KEY");
            uint256 private_key = vm.parseUint(string(abi.encodePacked("0x", privatekeyString)));
            
            vm.startBroadcast(private_key);

            LogToken token = new LogToken(100);

            TransferAutomation automation = new TransferAutomation(address(token));

            token.setTransferAutomation(address(automation));
            vm.stopBroadcast();

            return (token, automation);
        }
    }
}