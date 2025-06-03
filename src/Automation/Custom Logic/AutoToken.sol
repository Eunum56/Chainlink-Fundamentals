// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AutoToken
 * @author Mohammed Muzammil
 * @notice ERC20 token that can be minted by designated MintingController Contract
 * @dev Uses OpenZeppelin ERC20 and Ownable Contracts
 */
contract AutoToken is ERC20, Ownable {
    error AutoToken__InvalidTokenAddress();
    error AutoToken__NotMintingController();

    address public mintingController;

    constructor() ERC20("AutoToken", "AT") Ownable(msg.sender) {}

    modifier OnlyMintingController() {
        if (msg.sender != mintingController) {
            revert AutoToken__NotMintingController();
        }
        _;
    }

    /**
     * @notice Sets the MintingController Contract
     * @param _mintingController Address of the MintingController Contract
     */
    function setMintingController(address _mintingController) external onlyOwner {
        if (_mintingController == address(0)) {
            revert AutoToken__InvalidTokenAddress();
        }
        mintingController = _mintingController;
    }

    /**
     * @notice Mints new tokens to Owner address
     * @param _to Recipient address (Owner)
     * @param _amount Amount of tokens to mint (in wei)
     * @dev Only callable by the MintingController Contract
     */
    function mint(address _to, uint256 _amount) external OnlyMintingController {
        _mint(_to, _amount);
    }
}
