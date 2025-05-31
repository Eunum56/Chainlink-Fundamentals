// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract GameToken is ERC20, Ownable {
    // 0xb44024D10e3502E29BF622fd8Ee0e9b96C7BE141
    // Deployed on Ethereum Sepolia

    // 0x452A5709ed3dDDABfE0e0393f0ab5476e5f3105D
    // Deployed on Arbitrum Sepolia

    error GameToken__InvalidGameEngineAddress();
    error GameToken__NotGameEngine();

    address public gameEngine;

    constructor() ERC20("Game Token", "GT") Ownable(msg.sender) {}

    function setGameEngine(address _gameEngine) external onlyOwner {
        if (_gameEngine == address(0)) revert GameToken__InvalidGameEngineAddress();
        gameEngine = _gameEngine;
    }

    modifier onlyGameEngine() {
        if (msg.sender != gameEngine) revert GameToken__NotGameEngine();
        _;
    }

    function mint(address to, uint256 amount) external onlyGameEngine {
        _mint(to, amount);
    }

    function burn(address account, uint256 amountToBurn) external onlyGameEngine {
        _burn(account, amountToBurn);
    }
}
