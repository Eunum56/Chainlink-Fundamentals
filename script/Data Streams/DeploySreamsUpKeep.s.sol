// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {LogEmitter} from "src/Data Streams/LogEmitter.sol";
import {StreamsUpkeep} from "src/Data Streams/StreamsUpKeep.sol";

import {SUPHelperConfig} from "./SUPHelperConfig.s.sol";
import {RegisterUpKeep} from "./SUPInteractions.s.sol";

import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract DeployStreamsUpKeep is Script {
    uint256 constant LINK_SEND_AMOUNT = 5 ether; // 5 LINK

    function run() external returns (LogEmitter, StreamsUpkeep) {
        SUPHelperConfig helperConfig = new SUPHelperConfig();
        SUPHelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        RegisterUpKeep upKeep = new RegisterUpKeep();

        string memory privateKeyString = vm.envString("PRIVATE_KEY");
        uint256 private_key = vm.parseUint(string(abi.encodePacked("0x", privateKeyString)));

        console.log("Deploying contracts on chainId: ", block.chainid);
        vm.startBroadcast(private_key);

        LogEmitter emitter = new LogEmitter();

        StreamsUpkeep streamsUpKeep = new StreamsUpkeep(config.verifier, config.feedId);

        LinkTokenInterface(config.link).transfer(address(streamsUpKeep), LINK_SEND_AMOUNT);

        vm.stopBroadcast();

        upKeep.registerUpKeep(address(streamsUpKeep), address(emitter), config.registry, config.registrar, config.link);

        return (emitter, streamsUpKeep);
    }
}
