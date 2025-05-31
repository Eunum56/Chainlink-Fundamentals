// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {GameToken} from "../../../src/Data Feeds/Price Feeds/GameToken.sol";

contract GameTokenScript is Script {
    function run() public {
        console.log("Deploying the GameToken");
        vm.startBroadcast();
        GameToken token = new GameToken();
        vm.stopBroadcast();
        console.log("Token deployed on ", block.chainid);
        console.log("Token address", address(token));
    }
}
