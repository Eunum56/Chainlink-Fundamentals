// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";

import {FlexiToken} from "src/CCIP/FlexiToken.sol";
import {Vault} from "src/CCIP/Vault.sol";
import {FlexiTokenPool, IERC20} from "src/CCIP/FlexiTokenPool.sol";

import {IFlexiToken} from "src/CCIP/Interfaces/IFlexiToken.sol";

import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

import {RegistryModuleOwnerCustom} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import {TokenAdminRegistry} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";

contract DeployFlexiTokenScript is Script {
    function run() public returns (FlexiToken, FlexiTokenPool) {
        CCIPLocalSimulatorFork ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();

        Register.NetworkDetails memory networkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);

        vm.startBroadcast();

        FlexiToken token = new FlexiToken();
        FlexiTokenPool pool = new FlexiTokenPool(
            IERC20(address(token)), new address[](0), networkDetails.rmnProxyAddress, networkDetails.routerAddress
        );

        token.grantMintAndBurnRole(address(pool));

        RegistryModuleOwnerCustom(networkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(address(token));
        TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(token));
        TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).setPool(address(token), address(pool));

        vm.stopBroadcast();

        return (token, pool);
    }
}

contract DeployVaultScript is Script {
    function run(address _flexiToken) public returns (Vault) {
        vm.startBroadcast();

        Vault vault = new Vault(FlexiToken(_flexiToken));
        IFlexiToken(_flexiToken).grantMintAndBurnRole(address(vault));

        vm.stopBroadcast();

        return vault;
    }
}
