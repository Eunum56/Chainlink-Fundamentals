// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {GameEngine} from "../../../src/Data Feeds/Price Feeds/GameEngine.sol";

interface IGameToken {
    function setGameEngine(address) external;
}

contract GameEngineScript is Script {
    address ETHEREUM_SEPOLIA_TOKEN = 0xb44024D10e3502E29BF622fd8Ee0e9b96C7BE141;
    address ETHEREUM_SEPOLIA_PRICEFEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function run() public {
        string memory privateKeyString = vm.envString("PRIVATE_KEY");
        uint256 private_key = vm.parseUint(string(abi.encodePacked("0x", privateKeyString)));

        vm.startBroadcast(private_key);

        GameEngine engine = new GameEngine(ETHEREUM_SEPOLIA_TOKEN, ETHEREUM_SEPOLIA_PRICEFEED);
        IGameToken(ETHEREUM_SEPOLIA_TOKEN).setGameEngine(address(engine));

        vm.stopBroadcast();
        console.log("Engine address: ", address(engine));
    }
}
