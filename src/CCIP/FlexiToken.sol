// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// Type declarations
// errors
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

/**
 * @title FlexiToken
 * @author Mohammed Muzammil
 * @notice This is a cross-chain rebase token that incentivies users to deposite into a vault and gain interest in rewards
 * @notice The interest rate in the smart contract can only decrease
 * @notice Each user will have their own interest rate that is global interest rate the time of depositing
 */
contract FlexiToken is ERC20, Ownable, AccessControl {
    // ERRORS
    error FlexiToken__InterestRateCanOnlyDecrease(uint256 newInterestRate, uint256 oldInterestRate);

    // STATE VARIABLES
    uint256 private constant PRECISION_FACTOR = 1e18;
    bytes32 private constant MINT_AND_BURN_ROLE = keccak256("MINT_AND_BURN_ROLE");
    uint256 private s_interestRate = 5e10;

    mapping(address user => uint256 interestRate) private s_userInterestRate;
    mapping(address user => uint256 timeStamp) private s_userLastUpdatedTimestamp;
    // EVENTS

    event NewInterestRateSet(uint256 indexed newInterestRate);

    // MODIFIERS

    // FUNCTIONS
    constructor() ERC20("FlexiToken", "FLX") Ownable(msg.sender) {}

    // EXTERNAL FUNCTIONS
    function grantMintAndBurnRole(address _account) external onlyOwner {
        _grantRole(MINT_AND_BURN_ROLE, _account);
    }

    function setInterestRate(uint256 _newInterestRate) external onlyOwner {
        if (_newInterestRate < s_interestRate) {
            revert FlexiToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
        }

        s_interestRate = _newInterestRate;

        emit NewInterestRateSet(_newInterestRate);
    }

    function principleBalanceOf(address _user) external view returns (uint256) {
        return super.balanceOf(_user);
    }

    function mint(address _to, uint256 _amount) external {
        _mintAccruedInterest(_to);
        s_userInterestRate[_to] = s_interestRate;
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external {
        if (_amount == type(uint256).max) {
            _amount = balanceOf(_from);
        }
        _mintAccruedInterest(_from);
        _burn(_from, _amount);
    }

    // PUBLIC FUNCTIONS
    function balanceOf(address _user) public view override returns (uint256) {
        return super.balanceOf(_user) * _calculateUserAccumulatedInterest(_user) / PRECISION_FACTOR;
    }

    function transfer(address _to, uint256 _amount) public override returns (bool) {
        _mintAccruedInterest(msg.sender);
        _mintAccruedInterest(_to);

        if (_amount == type(uint256).max) {
            _amount = balanceOf(msg.sender);
        }

        if (balanceOf(_to) == 0) {
            s_userInterestRate[_to] = s_userInterestRate[msg.sender];
        }

        return super.transfer(_to, _amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public override returns (bool) {
        _mintAccruedInterest(_from);
        _mintAccruedInterest(_to);

        if (_amount == type(uint256).max) {
            _amount = balanceOf(_from);
        }

        if (balanceOf(_to) == 0) {
            s_userInterestRate[_to] = s_userInterestRate[_from];
        }

        return super.transferFrom(_from, _to, _amount);
    }

    // INTERNAL FUNCTIONS
    function _mintAccruedInterest(address _user) internal {
        // 1. Find the principle balance
        uint256 principleBalance = super.balanceOf(_user);

        // 2. Find the current Balance incuding accumulated interest that has not minted
        uint256 currentBalance = balanceOf(_user);

        // 3. Get the interest to mint and mints them 2 - 1 => interestToMint;
        uint256 interestToMint = currentBalance - principleBalance;

        // Update the last timestamp for this user
        s_userLastUpdatedTimestamp[_user] = block.timestamp;

        // Mints the interest tokens
        _mint(_user, interestToMint);
    }

    function _calculateUserAccumulatedInterest(address _user) internal view returns (uint256) {
        // this is going to be linear growth with time
        // 1. calculate the time since the last update
        // 2. calculate the amount of linear growth
        //priciple amount(l + (user interest rate * time elapsed))
        // deposit: 10 tokens
        // interest rate 0.5 tokens per second
        // time elapsed is 2 seconds
        // 10 + (10 * 0.5 * 2)
        uint256 lastTImeElapsed = block.timestamp - s_userLastUpdatedTimestamp[_user];
        uint256 linearInterest = PRECISION_FACTOR + (s_userInterestRate[_user] * lastTImeElapsed);
        return linearInterest;
    }

    // PRIVATE FUNCTIONS

    // VIEW AND PURE FUNCTION
    function getInterestRate() external view returns (uint256) {
        return s_interestRate;
    }

    function getUserInterestRate(address _user) external view returns (uint256) {
        return s_userInterestRate[_user];
    }

    function getUserLastUpdatedTimestamp(address _user) external view returns (uint256) {
        return s_userLastUpdatedTimestamp[_user];
    }
}
