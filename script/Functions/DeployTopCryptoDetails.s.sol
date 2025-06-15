// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

import {TopCryptoDetails} from "src/Functions/TopCryptoDetails.sol";
import {TCDHelperConfig} from "./TCDHelperConfig.s.sol";

import {CreateSubscription, FundSubscription, AddConsumer} from "./TCDInteractions.s.sol";

contract DeployTopCryptoDetails is Script {
    uint256 constant LOCAL_CHAINID = 31337;

    error DeployTopCryptoDetails__CannotDeployOnLocalChain();

    TCDHelperConfig helperConfig;

    function run() external {
        helperConfig = new TCDHelperConfig();

        if (block.chainid == LOCAL_CHAINID) {
            // deployOnLocalChain();
            revert DeployTopCryptoDetails__CannotDeployOnLocalChain();
        } else {
            deployTopCryptoDetails();
        }
    }

    function deployTopCryptoDetails() internal {
        TCDHelperConfig.NetworkConfig memory config = helperConfig.getNetworkConfig();

        // create subscription
        CreateSubscription createSub = new CreateSubscription();
        uint64 subId = createSub.createSubscription(config.routerAddress);

        // fund subscription
        FundSubscription fundSub = new FundSubscription();
        fundSub.fundSubscription(config.linkAddress, config.routerAddress, subId);

        string memory privateKeyString = vm.envString("PRIVATE_KEY");
        uint256 private_key = vm.parseUint(string(abi.encodePacked("0x", privateKeyString)));

        console.log("Deploying main contract");
        vm.startBroadcast(private_key);
        TopCryptoDetails topCryptoDetails = new TopCryptoDetails(subId, config.routerAddress, config.donId);
        vm.stopBroadcast();
        console.log("Deployed on chainId", block.chainid);
        console.log("Main contract deployed", address(topCryptoDetails));

        // Add consumer
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(config.routerAddress, subId, address(topCryptoDetails));
    }
}
