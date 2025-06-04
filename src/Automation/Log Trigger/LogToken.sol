// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title LogToken
 * @author Mohammed Muzammil
 * @notice A ERC0 token that reward/mints to the user via Chainlink automation
 * @notice Only TransferAutomation contract can mint new tokens to the user as rewards
 */
contract LogToken is ERC20, Ownable {

    // ERRORS
    error LogToken__InvalidTransferAutomationAddress();
    error LogToken__NotTransferAutomation();
    error LogToken__InvalidAddress();
    error LogToken__TransferAutomationAddressNotSet();

    // EVENTS

    // STATE VARIABLES
    uint256 private s_rewardAmount;
    address private s_transferAutomation;

    // MODIFIERS
    modifier onlyTransferAutomation {
        if(msg.sender != s_transferAutomation) {
            revert LogToken__NotTransferAutomation();
        }
        _;
    }

    // FUNCTIONS
    /**
     * @notice Initialize the Token name and symbol
     * @param _rewardAmount Initial RewardAmount of the Tokens
     */
    constructor(uint256 _rewardAmount) ERC20("LogToken", "LT") Ownable(msg.sender) {
        s_rewardAmount = _rewardAmount;
    }

    // EXTERNAL FUNCTOINS
    /**
     * @notice Can only be called by owner
     * @param newTransferAutomation The address of TransferAutomation contract
     */
    function setTransferAutomation(address newTransferAutomation) external onlyOwner {
        if(newTransferAutomation == address(0)) {
            revert LogToken__InvalidTransferAutomationAddress();
        }
        s_transferAutomation = newTransferAutomation;

    }


    /**
     * @notice Only TransferAutomation can call this function to mint new tokens
     * @param _to The address of the user
     * @param _amount The amount of tokens to mint
     */
    function mint(address _to, uint256 _amount) external onlyTransferAutomation {
        if(address(0) == _to) {
            revert LogToken__InvalidAddress();
        }
        if(s_transferAutomation == address(0)) {
            revert LogToken__TransferAutomationAddressNotSet();
        }
        _mint(_to, _amount);
    }

    /**
     * @notice Updates the reward amount
     * @param newRewardAmount New reward amount
     */
    function changeRewardAmount(uint256 newRewardAmount) external onlyOwner {
        s_rewardAmount = newRewardAmount;
    }


    // GETTERS
    function getRewardAmount() external view returns(uint256) {
        return s_rewardAmount;
    }

    function getTransferAutomation() external view returns(address) {
        return s_transferAutomation;
    }
}