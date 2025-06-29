// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TokenPool, IERC20} from "@ccip/contracts/src/v0.8/ccip/pools/TokenPool.sol";
import {Pool} from "@ccip/contracts/src/v0.8/ccip/libraries/Pool.sol";

import {IFlexiToken} from "./Interfaces/IFlexiToken.sol";

contract FlexiTokenPool is TokenPool {
    constructor(IERC20 _token, address[] memory _allowlist, address _rmnProxy, address _router)
        TokenPool(_token, _allowlist, _rmnProxy, _router)
    {}

    function lockOrBurn(Pool.LockOrBurnInV1 calldata lockOrBurnIn)
        external
        returns (Pool.LockOrBurnOutV1 memory lockOrBurnOut)
    {
        _validateLockOrBurn(lockOrBurnIn);
        uint256 userInterestRate = IFlexiToken(address(i_token)).getUserInterestRate(lockOrBurnIn.originalSender);
        IFlexiToken(address(i_token)).burn(address(this), lockOrBurnIn.amount);

        lockOrBurnOut = Pool.LockOrBurnOutV1({
            destTokenAddress: getRemoteToken(lockOrBurnIn.remoteChainSelector), // retruns in bytes format
            destPoolData: abi.encode(userInterestRate)
        });
    }

    function releaseOrMint(Pool.ReleaseOrMintInV1 calldata releaseOrMintIn)
        external
        returns (Pool.ReleaseOrMintOutV1 memory)
    {
        _validateReleaseOrMint(releaseOrMintIn);

        // uint256 userInterestRate = abi.decode(releaseOrMintIn.sourcePoolData, (uint256));
        // In this project im not using interest rate to transfer this as data cross chain. Only tokens are transfering cross-chain.

        IFlexiToken(address(i_token)).mint(releaseOrMintIn.receiver, releaseOrMintIn.amount);

        Pool.ReleaseOrMintOutV1 memory releaseOrMintOutV1 =
            Pool.ReleaseOrMintOutV1({destinationAmount: releaseOrMintIn.amount});

        return releaseOrMintOutV1;
    }
}
