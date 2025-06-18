// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

contract SUPHelperConfig is Script {
    error SUPHelperConfig__InvalidChain();

    struct NetworkConfig {
        address verifier;
        string feedId;
        address link;
        address registry;
        address registrar;
    }

    // ETH mainnet
    address ETH_VERIFIER = 0x5A1634A86e9b7BfEf33F0f3f3EA3b1aBBc4CC85F;
    string ETH_FEED_ID = "0x000362205e10b3a147d02792eccee483dca6c7b44ecce7012cb8c6e0b68b3ae9";
    // Automation values
    address ETH_LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address ETH_REGISTRY = 0x6593c7De001fC8542bB1703532EE1E5aA0D458fD;
    address ETH_REGISTRAR = 0x6B0B234fB2f380309D47A7E9391E29E9a179395a;

    // ETH sepolia
    address ETH_SEPOLIA_VERIFIER = 0x4e9935be37302B9C97Ff4ae6868F1b566ade26d2;
    string ETH_SEPOLIA_FEED_ID = "0x000359843a543ee2fe414dc14c7e7920ef10f4372990b79d6361cdc0dd1ba782";
    // Automation values
    address ETH_SEPOLIA_LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address ETH_SEPOLIA_REGISTRY = 0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad;
    address ETH_SEPOLIA_REGISTRAR = 0xb0E49c5D0d05cbc241d68c05BC5BA1d1B7B72976;

    // ARB mainnet
    address ARB_VERIFIER = 0x478Aa2aC9F6D65F84e09D9185d126c3a17c2a93C;
    string ARB_FEED_ID = "0x00030ab7d02fbba9c6304f98824524407b1f494741174320cfd17a2c22eec1de";
    // Automation values
    address ARB_LINK = 0xf97f4df75117a78c1A5a0DBb814Af92458539FB4;
    address ARB_REGISTRY = 0x37D9dC70bfcd8BC77Ec2858836B923c560E891D1;
    address ARB_REGISTRAR = 0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad;

    // ARB sepolia
    address ARB_SEPOLIA_VERIFIER = 0x2ff010DEbC1297f19579B4246cad07bd24F2488A;
    string ARB_SEPOLIA_FEED_ID = "0x0003c90f4d0e133914a02466e44f3392560c86248925ce651ef8e44f1ec2ef4a";
    // Automation values
    address ARB_SEPOLIA_LINK = 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E;
    address ARB_SEPOLIA_REGISTRY = 0x8194399B3f11fcA2E8cCEfc4c9A658c61B8Bf412;
    address ARB_SEPOLIA_REGISTRAR = 0x881918E24290084409DaA91979A30e6f0dB52eBe;

    // OP sepolia
    address OP_SEPOLIA_VERIFIER = 0x5f64394a2Ab3AcE9eCC071568Fc552489a8de7AF;
    string OP_SEPOLIA_FEED_ID = "0x000305a183fedd7f783d99ac138950cff229149703d2a256d61227ad1e5e66ea";
    // Automation values
    address OP_SEPOLIA_LINK = 0xE4aB69C077896252FAFBD49EFD26B5D171A32410;
    address OP_SEPOLIA_REGISTRY = 0x881918E24290084409DaA91979A30e6f0dB52eBe;
    address OP_SEPOLIA_REGISTRAR = 0x110Bd89F0B62EA1598FfeBF8C0304c9e58510Ee5;

    // BASE mainnet
    address BASE_VERIFIER = 0xDE1A28D87Afd0f546505B28AB50410A5c3a7387a;
    string BASE_FEED_ID = "";
    // Automation values
    address BASE_LINK = 0x88Fb150BDc53A65fe94Dea0c9BA0a6dAf8C6e196;
    address BASE_REGISTRY = 0xf4bAb6A129164aBa9B113cB96BA4266dF49f8743;
    address BASE_REGISTRAR = 0xE28Adc50c7551CFf69FCF32D45d037e5F6554264;

    // BASE sepolia
    address BASE_SEPOLIA_VERIFIER = 0x8Ac491b7c118a0cdcF048e0f707247fD8C9575f9;
    string BASE_SEPOLIA_FEED_ID = "";
    // Automation values
    address BASE_SEPOLIA_LINK = 0xE4aB69C077896252FAFBD49EFD26B5D171A32410;
    address BASE_SEPOLIA_REGISTRY = 0x91D4a4C3D448c7f3CB477332B1c7D420a5810aC3;
    address BASE_SEPOLIA_REGISTRAR = 0xf28D56F3A707E25B71Ce529a21AF388751E1CF2A;

    NetworkConfig activeNetworkConfig;

    uint256 ETH_CHAINID = 1;
    uint256 ETH_SEPOLIA_CHAINID = 11155111;
    uint256 ARB_CHAINID = 42161;
    uint256 ARB_SEPOLIA_CHAINID = 421614;
    uint256 BASE_CHAINID = 8453;
    uint256 BASE_SEPOLIA_CHAINID = 84532;
    uint256 OP_SEPOLIA_CHAINID = 11155420;

    constructor() {
        if (block.chainid == ETH_CHAINID) {
            activeNetworkConfig = getEthConfig();
        } else if (block.chainid == ETH_SEPOLIA_CHAINID) {
            activeNetworkConfig = getEthSepoliaConfig();
        } else if (block.chainid == ARB_CHAINID) {
            activeNetworkConfig = getArbConfig();
        } else if (block.chainid == ARB_SEPOLIA_CHAINID) {
            activeNetworkConfig = getArbSepoliaConfig();
        } else if (block.chainid == OP_SEPOLIA_CHAINID) {
            activeNetworkConfig = getOpSepoliaConfig();
        } else {
            revert SUPHelperConfig__InvalidChain();
        }
    }

    function getConfig() external view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }

    function getEthConfig() internal view returns (NetworkConfig memory) {
        return NetworkConfig({
            verifier: ETH_VERIFIER,
            feedId: ETH_FEED_ID,
            link: ETH_LINK,
            registry: ETH_REGISTRY,
            registrar: ETH_REGISTRAR
        });
    }

    function getEthSepoliaConfig() internal view returns (NetworkConfig memory) {
        return NetworkConfig({
            verifier: ETH_SEPOLIA_VERIFIER,
            feedId: ETH_SEPOLIA_FEED_ID,
            link: ETH_SEPOLIA_LINK,
            registry: ETH_SEPOLIA_REGISTRY,
            registrar: ETH_SEPOLIA_REGISTRAR
        });
    }

    function getArbConfig() internal view returns (NetworkConfig memory) {
        return NetworkConfig({
            verifier: ARB_VERIFIER,
            feedId: ARB_FEED_ID,
            link: ARB_LINK,
            registry: ARB_REGISTRY,
            registrar: ARB_REGISTRAR
        });
    }

    function getArbSepoliaConfig() internal view returns (NetworkConfig memory) {
        return NetworkConfig({
            verifier: ARB_SEPOLIA_VERIFIER,
            feedId: ARB_SEPOLIA_FEED_ID,
            link: ARB_SEPOLIA_LINK,
            registry: ARB_SEPOLIA_REGISTRY,
            registrar: ARB_SEPOLIA_REGISTRAR
        });
    }

    function getOpSepoliaConfig() internal view returns (NetworkConfig memory) {
        return NetworkConfig({
            verifier: OP_SEPOLIA_VERIFIER,
            feedId: OP_SEPOLIA_FEED_ID,
            link: OP_SEPOLIA_LINK,
            registry: OP_SEPOLIA_REGISTRY,
            registrar: OP_SEPOLIA_REGISTRAR
        });
    }
}
