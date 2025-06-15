// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";

import {IFunctionsSubscriptions} from
    "@chainlink/contracts/src/v0.8/functions/dev/v1_X/interfaces/IFunctionsSubscriptions.sol";
import {IERC677} from "@chainlink/contracts/src/v0.8/shared/token/ERC677/IERC677.sol";

contract CreateSubscription is Script {
    function createSubscription(address routerAddress) public returns (uint64) {
        // create subscription
        console.log("Creating subscription");

        vm.startBroadcast();
        uint64 subId = IFunctionsSubscriptions(routerAddress).createSubscription();
        vm.stopBroadcast();

        console.log("Subscription created", subId);

        return subId;
    }
}

contract FundSubscription is Script {
    uint256 constant LINK_FUND_AMOUNT = 5 ether; // 5 LINK

    function fundSubscription(address linkAddress, address routerAddress, uint64 subId) public {
        // fund subscription
        console.log("Funding subscription");

        vm.startBroadcast();
        IERC677(linkAddress).transferAndCall(routerAddress, LINK_FUND_AMOUNT, abi.encode(subId));
        vm.stopBroadcast();

        console.log("Subscription funded with", LINK_FUND_AMOUNT);
    }
}

contract AddConsumer is Script {
    function addConsumer(address routerAddress, uint64 subId, address topCryptoDetails) public {
        // Add consumer
        console.log("Adding consumer");

        vm.startBroadcast();
        IFunctionsSubscriptions(routerAddress).addConsumer(subId, topCryptoDetails);
        vm.stopBroadcast();

        console.log("Consumer added successfully");
    }
}
