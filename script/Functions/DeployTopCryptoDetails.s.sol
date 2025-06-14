// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";

import {TopCryptoDetails} from "src/Functions/TopCryptoDetails.sol";
import {TCDHelperConfig} from "./TCDHelperConfig.s.sol";

contract DeployTopCryptoDetails is Script {

    function run() external returns(TopCryptoDetails, TCDHelperConfig) {

    }
}