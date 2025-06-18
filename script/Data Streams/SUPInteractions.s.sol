// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {IKeeperRegistryMaster} from "@chainlink/contracts/src/v0.8/automation/interfaces/v2_1/IKeeperRegistryMaster.sol";

interface IAutomationRegistrar2_1 {
    struct RegistrationParams {
        string name;
        bytes encryptedEmail;
        address upkeepContract;
        uint32 gasLimit;
        address adminAddress;
        uint8 triggerType;
        bytes checkData;
        bytes triggerConfig;
        bytes offchainConfig;
        uint96 amount;
    }
    /**
     * string name = "test upkeep";
     * bytes encryptedEmail = 0x;
     * address upkeepContract = 0x...;
     * uint32 gasLimit = 500000;
     * address adminAddress = 0x....;
     * uint8 triggerType = 0;
     * bytes checkData = 0x;
     * bytes triggerConfig = 0x;
     * bytes offchainConfig = 0x;
     * uint96 amount = 1000000000000000000;
     */

    struct LogTriggerConfig {
        address contractAddress; // must have address that will be emitting the log
        uint8 filterSelector; // must have filtserSelector, denoting  which topics apply to filter ex 000, 101, 111...only last 3 bits apply
        bytes32 topic0; // must have signature of the emitted event
        bytes32 topic1; // optional filter on indexed topic 1
        bytes32 topic2; // optional filter on indexed topic 2
        bytes32 topic3; // optional filter on indexed topic 3
    }

    /**
     * Log trigger details
     * address contractAddress = 0x...; // e.g. 0x2938ff7cAB3115f768397602EA1A1a0Aa20Ac42f
     * uint8 filterSelector = 1; // see filterSelector
     * bytes32 topic0 = 0x...; // e.g. 0x74500d2e71ee75a8a83dcc87f7316a89404a0d0ac0c725e80c956dbf16fb8133 for event called bump
     * bytes32 topic1 = 0x...; // e.g. bytes32 of address 0x000000000000000000000000c26d7ef337e01a5cc5498d3cc2ff0610761ae637
     * bytes32 topic2 = 0x; // empty so 0x
     * bytes32 topic3 = 0x; // empty so 0x
     */
    function registerUpkeep(RegistrationParams calldata requestParams) external returns (uint256);
}

contract RegisterUpKeep is Script {
    error SUPInteractions__RegistrationFailed();

    uint96 constant FUND_UPKEEP_AMOUNT = 5 ether; // 5 LINK
    uint32 constant GAS_LIMIT = 500000;

    function registerUpKeep(
        address _streamsUpKeep,
        address _logEmitter,
        address _registry,
        address _registrar,
        address _linkToken
    ) external returns (uint256) {
        vm.startBroadcast();

        console.log("Preparing triggerConfig...");
        IAutomationRegistrar2_1.LogTriggerConfig memory triggerConfigStruct = IAutomationRegistrar2_1.LogTriggerConfig({
            contractAddress: _logEmitter,
            filterSelector: 1,
            topic0: keccak256("Log(address)"),
            topic1: bytes32(0),
            topic2: bytes32(0),
            topic3: bytes32(0)
        });
        bytes memory triggerConfig = abi.encode(triggerConfigStruct); // Encode as bytes

        // bytes memory triggerConfig = abi.encode(
        //     _logEmitter,
        //     uint8(1), // topic0 only
        //     keccak256("Log(address)"),
        //     bytes32(0),
        //     bytes32(0),
        //     bytes32(0)
        // );

        console.log("Building registration params...");
        console.log("With admin", tx.origin);
        IAutomationRegistrar2_1.RegistrationParams memory params = IAutomationRegistrar2_1.RegistrationParams({
            name: "Streams Upkeep",
            encryptedEmail: "",
            upkeepContract: _streamsUpKeep,
            gasLimit: GAS_LIMIT,
            adminAddress: tx.origin,
            triggerType: 1, // 0 = Custom Logic, 1 = log trigger
            checkData: "",
            triggerConfig: triggerConfig,
            offchainConfig: "",
            amount: FUND_UPKEEP_AMOUNT
        });

        console.log("Approving LINK to registrar...");
        LinkTokenInterface link = LinkTokenInterface(_linkToken);
        link.approve(_registrar, FUND_UPKEEP_AMOUNT);

        console.log("Registering upkeep through registrar...");
        uint256 upkeepId = IAutomationRegistrar2_1(_registrar).registerUpkeep(params);

        if (upkeepId == 0) revert SUPInteractions__RegistrationFailed();

        console.log("Upkeep registered! ID:", upkeepId);

        uint8 triggerType = IKeeperRegistryMaster(_registry).getTriggerType(upkeepId);
        console.log("Trigger Type:", triggerType);

        vm.stopBroadcast();

        return upkeepId;
    }
}
