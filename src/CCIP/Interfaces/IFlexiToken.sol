// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IFlexiToken {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function getUserInterestRate(address user) external view returns (uint256);
    function getInterestRate() external view returns (uint256);
    function grantMintAndBurnRole(address account) external;
}
