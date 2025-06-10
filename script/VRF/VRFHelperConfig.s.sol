// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";

contract VRFHelperConfig is Script {
    error VRFHelperConfig__InvalidChainID();

    struct NetworkConfig {
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subId;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getETHSepoliaConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getEthConfig();
        } else if (block.chainid == 421614) {
            activeNetworkConfig = getArbSepolia();
        } else {
            revert VRFHelperConfig__InvalidChainID();
        }
    }

    function getConfig() external view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }

    function getETHSepoliaConfig() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subId: 29860539656896153165350837408191121491454210802315698920730024210840967735171
        });
    }

    function getEthConfig() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({
            // DUMMY VALUES
            vrfCoordinator: address(2),
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subId: 1
        });
    }

    function getArbSepolia() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({
            // DUMMY VALUES
            vrfCoordinator: address(2),
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subId: 1
        });
    }
}
