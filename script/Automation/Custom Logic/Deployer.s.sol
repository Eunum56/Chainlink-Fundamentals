// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {AutoToken} from "src/Automation/Custom Logic/AutoToken.sol";
import {MintingController} from "src/Automation/Custom Logic/MintingController.sol";

contract Deployer is Script {
    function run() public {
        string memory privateKeyString = vm.envString("PRIVATE_KEY");
        uint256 private_key = vm.parseUint(string(abi.encodePacked("0x", privateKeyString)));

        vm.startBroadcast(private_key);

        AutoToken token = new AutoToken();
        MintingController controller = new MintingController(address(token));

        token.setMintingController(address(controller));

        vm.stopBroadcast();
    }
}
