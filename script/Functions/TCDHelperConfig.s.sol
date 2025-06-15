// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";

import {TopCryptoDetails} from "src/Functions/TopCryptoDetails.sol";

contract TCDHelperConfig is Script {
    struct NetworkConfig {
        address routerAddress;
        address linkAddress;
        bytes32 donId;
    }

    error TCDHelperConfig__InvalidChainId();

    // ETH_MAINNET
    address ETH_ROUTER = 0x65Dcc24F8ff9e51F10DCc7Ed1e4e2A61e6E14bd6;
    address ETH_LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    bytes32 ETH_DONID = 0x66756e2d657468657265756d2d6d61696e6e65742d3100000000000000000000;

    // ETH_Sepolia
    address ETH_SEPOLIA_ROUTER = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    address ETH_SEPOLIA_LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    bytes32 ETH_SEPOLIA_DONID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    // ARB_MAINNET
    address ARB_ROUTER = 0x97083E831F8F0638855e2A515c90EdCF158DF238;
    address ARB_LINK = 0xf97f4df75117a78c1A5a0DBb814Af92458539FB4;
    bytes32 ARB_DONID = 0x66756e2d617262697472756d2d6d61696e6e65742d3100000000000000000000;

    // ARB_SEPOLIA
    address ARB_SEPOLIA_ROUTER = 0x234a5fb5Bd614a7AA2FfAB244D603abFA0Ac5C5C;
    address ARB_SEPOLIA_LINK = 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E;
    bytes32 ARB_SEPOLIA_DONID = 0x66756e2d617262697472756d2d7365706f6c69612d3100000000000000000000;

    uint256 ETH_CHAINID = 1;
    uint256 ETH_SEPOLIA_CHAINID = 11155111;
    uint256 ARB_CHAINID = 42161;
    uint256 ARB_SEPOLIA_CHAINID = 421614;

    NetworkConfig activeNetworkConfig;

    constructor() {
        if (block.chainid == ETH_CHAINID) {
            activeNetworkConfig = getEthConfig();
        } else if (block.chainid == ETH_SEPOLIA_CHAINID) {
            activeNetworkConfig = getEthSepoliaConfig();
        } else if (block.chainid == ARB_CHAINID) {
            activeNetworkConfig = getArbConfig();
        } else if (block.chainid == ARB_SEPOLIA_CHAINID) {
            activeNetworkConfig = getArbSepoliaConfig();
        } else {
            revert TCDHelperConfig__InvalidChainId();
        }
    }

    function getNetworkConfig() external view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }

    function getEthConfig() private view returns (NetworkConfig memory) {
        return NetworkConfig({routerAddress: ETH_ROUTER, linkAddress: ETH_LINK, donId: ETH_DONID});
    }

    function getEthSepoliaConfig() private view returns (NetworkConfig memory) {
        return
            NetworkConfig({routerAddress: ETH_SEPOLIA_ROUTER, linkAddress: ETH_SEPOLIA_LINK, donId: ETH_SEPOLIA_DONID});
    }

    function getArbConfig() private view returns (NetworkConfig memory) {
        return NetworkConfig({routerAddress: ARB_ROUTER, linkAddress: ARB_LINK, donId: ARB_DONID});
    }

    function getArbSepoliaConfig() private view returns (NetworkConfig memory) {
        return
            NetworkConfig({routerAddress: ARB_SEPOLIA_ROUTER, linkAddress: ARB_SEPOLIA_LINK, donId: ARB_SEPOLIA_DONID});
    }
}
