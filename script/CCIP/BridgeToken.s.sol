// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";

import {IRouterClient} from "@ccip/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@ccip/contracts/src/v0.8/ccip/libraries/Client.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BridgeTokenScript is Script {
    function run(
        address routerAddress,
        uint64 destinationChainSelector,
        address receiverAddress,
        address tokenAddress,
        uint256 amountToSend,
        address linkTokenAddress
    ) public {
        // struct EVMTokenAmount {
        //     address token; // token address on the local chain.
        //     uint256 amount; // Amount of tokens.
        // }
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({token: tokenAddress, amount: amountToSend});
        // struct EVM2AnyMessage {
        //     bytes receiver; // abi.encode(receiver address) for dest EVM chains
        //     bytes data; // Data payload
        //     EVMTokenAmount[] tokenAmounts; // Token transfers
        //     address feeToken; // Address of feeToken. address(0) means you will send msg.value.
        //     bytes extraArgs; // Populate this with _argsToBytes(EVMExtraArgsV2)
        // }
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiverAddress),
            data: "",
            tokenAmounts: tokenAmounts,
            feeToken: linkTokenAddress,
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 0}))
        });

        vm.startBroadcast();
        uint256 fee = IRouterClient(routerAddress).getFee(destinationChainSelector, message);

        IERC20(linkTokenAddress).approve(routerAddress, fee);

        IERC20(tokenAddress).approve(routerAddress, amountToSend);

        IRouterClient(routerAddress).ccipSend(destinationChainSelector, message);
        vm.stopBroadcast();
    }
}
