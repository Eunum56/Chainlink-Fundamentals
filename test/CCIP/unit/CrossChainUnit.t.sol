// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {FlexiToken} from "src/CCIP/FlexiToken.sol";
import {Vault} from "src/CCIP/Vault.sol";
import {FlexiTokenPool, IERC20} from "src/CCIP/FlexiTokenPool.sol";
import {IFlexiToken} from "src/CCIP/Interfaces/IFlexiToken.sol";

import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

import {RegistryModuleOwnerCustom} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import {TokenAdminRegistry} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";
import {TokenPool} from "@ccip/contracts/src/v0.8/ccip/pools/TokenPool.sol";

import {RateLimiter} from "@ccip/contracts/src/v0.8/ccip/libraries/RateLimiter.sol";
import {Client} from "@ccip/contracts/src/v0.8/ccip/libraries/Client.sol";

import {IRouterClient} from "@ccip/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";

contract CrossChainUnit is Test {
    FlexiToken ethToken;
    FlexiToken arbToken;
    Vault vault;

    FlexiTokenPool ethSepoliaPool;
    FlexiTokenPool arbSepoliaPool;

    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address user2 = makeAddr("user2");
    uint256 constant SEND_VALUE = 1e5;

    uint256 ethSepoliaFork;
    uint256 arbSepoliaFork;

    CCIPLocalSimulatorFork ccipLocalSimulatorFork;
    Register.NetworkDetails ethSepoliaNetworkDetails;
    Register.NetworkDetails arbSepoliaNetworkDetails;

    function setUp() public {
        string memory eth_sepolia_rpcurl = vm.envString("ALCHEMY_SEPOLIA_RPC_URL");
        string memory arb_sepolia_rpcurl = vm.envString("ALCHEMY_ARB_SEPOLIA_RPC_URL");

        // vm.createSelectFork creates a new fork and selects it.
        ethSepoliaFork = vm.createSelectFork(eth_sepolia_rpcurl);
        // vm.createFork creates a new fork.
        // we can change fork using vm.selectFork and passing the fork.
        arbSepoliaFork = vm.createFork(arb_sepolia_rpcurl);

        // OR add this in foundry.toml.
        //rpc_endpoints = {eth-sepolia: "", arb-sepolia: ""}
        // than use in createSelectFork or createFork directly..... I'm not using cause i don't want to expose my rpc endpoints

        ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        vm.makePersistent(address(ccipLocalSimulatorFork));

        // Deploy and configure on eth sepolia
        // 1. Select the fork. (ethSepolia) fork already selected.
        // 2. Deploy token and vault contracts
        // 3. Get all addressess ex: rmnProxy, router etc for deploying pool contract by using Register.NetworkDetails and call ccipLocalSimulatorFork.getNetworkDetails()

        // It takes chainId we are already in eth-sepolia environment se we can pass block.chainid to get sepolia chainid
        vm.selectFork(ethSepoliaFork);
        ethSepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);

        vm.startPrank(owner);

        ethToken = new FlexiToken();
        vault = new Vault(ethToken);

        ethSepoliaPool = new FlexiTokenPool(
            IERC20(address(ethToken)),
            new address[](0),
            ethSepoliaNetworkDetails.rmnProxyAddress,
            ethSepoliaNetworkDetails.routerAddress
        );

        ethToken.grantMintAndBurnRole(address(vault));
        ethToken.grantMintAndBurnRole(address(ethSepoliaPool));

        RegistryModuleOwnerCustom(ethSepoliaNetworkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(
            address(ethToken)
        );
        TokenAdminRegistry(ethSepoliaNetworkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(ethToken));
        TokenAdminRegistry(ethSepoliaNetworkDetails.tokenAdminRegistryAddress).setPool(
            address(ethToken), address(ethSepoliaPool)
        );

        vm.stopPrank();

        // Deploy an configure on arb sepolia
        // 1. Select or change the fork to arb sepolia
        // 2. Deploy token and vault contracts
        // 3. Get all addressess ex: rmnProxy, router etc for deploying pool contract by using Register.NetworkDetails and call ccipLocalSimulatorFork.getNetworkDetails()

        vm.selectFork(arbSepoliaFork);
        // It takes chainId we are already in arb-sepolia environment se we can pass block.chainid to get sepolia chainid
        arbSepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);

        vm.startPrank(owner);

        arbToken = new FlexiToken();
        arbSepoliaPool = new FlexiTokenPool(
            IERC20(address(arbToken)),
            new address[](0),
            arbSepoliaNetworkDetails.rmnProxyAddress,
            arbSepoliaNetworkDetails.routerAddress
        );

        arbToken.grantMintAndBurnRole(address(arbSepoliaPool));

        RegistryModuleOwnerCustom(arbSepoliaNetworkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(
            address(arbToken)
        );
        TokenAdminRegistry(arbSepoliaNetworkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(arbToken));
        TokenAdminRegistry(arbSepoliaNetworkDetails.tokenAdminRegistryAddress).setPool(
            address(arbToken), address(arbSepoliaPool)
        );

        vm.stopPrank();

        configureTokenPool(
            ethSepoliaFork,
            address(ethSepoliaPool),
            arbSepoliaNetworkDetails.chainSelector,
            true,
            address(arbSepoliaPool),
            address(arbToken)
        );

        configureTokenPool(
            arbSepoliaFork,
            address(arbSepoliaPool),
            ethSepoliaNetworkDetails.chainSelector,
            true,
            address(ethSepoliaPool),
            address(ethToken)
        );
    }

    function configureTokenPool(
        uint256 fork,
        address localPool,
        uint64 remoteChainSelector,
        bool isAllowed,
        address remotePoolAddress,
        address remoteTokenAddress
    ) public {
        vm.selectFork(fork);
        vm.prank(owner);
        //   struct ChainUpdate {
        //     uint64 remoteChainSelector; // ──╮ Remote chain selector
        //     bool allowed; // ────────────────╯ Whether the chain should be enabled
        //     bytes remotePoolAddress; //        Address of the remote pool, ABI encoded in the case of a remote EVM chain.
        //     bytes remoteTokenAddress; //       Address of the remote token, ABI encoded in the case of a remote EVM chain.
        //     RateLimiter.Config outboundRateLimiterConfig; // Outbound rate limited config, meaning the rate limits for all of the onRamps for the given chain
        //     RateLimiter.Config inboundRateLimiterConfig; // Inbound rate limited config, meaning the rate limits for all of the offRamps for the given chain
        // }

        //   struct Config {
        //     bool isEnabled; // Indication whether the rate limiting should be enabled
        //     uint128 capacity; // ────╮ Specifies the capacity of the rate limiter
        //     uint128 rate; //  ───────╯ Specifies the rate of the rate limiter
        // }

        TokenPool.ChainUpdate[] memory chains = new TokenPool.ChainUpdate[](1);
        chains[0] = TokenPool.ChainUpdate({
            remoteChainSelector: remoteChainSelector,
            allowed: isAllowed,
            remotePoolAddress: abi.encode(remotePoolAddress),
            remoteTokenAddress: abi.encode(remoteTokenAddress),
            outboundRateLimiterConfig: RateLimiter.Config({isEnabled: false, capacity: 0, rate: 0}),
            inboundRateLimiterConfig: RateLimiter.Config({isEnabled: false, capacity: 0, rate: 0})
        });
        TokenPool(localPool).applyChainUpdates(chains);
    }

    function bridgeTokens(
        uint256 amountToBridge,
        uint256 localFork,
        uint256 remoteFork,
        Register.NetworkDetails memory localNetworkDetails,
        Register.NetworkDetails memory remoteNetworkDetails,
        address localToken,
        address remoteToken
    ) public {
        vm.selectFork(localFork);
        // struct EVMTokenAmount {
        //     address token; // token address on the local chain.
        //     uint256 amount; // Amount of tokens.
        // }
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({token: localToken, amount: amountToBridge});

        // struct EVM2AnyMessage {
        //     bytes receiver; // abi.encode(receiver address) for dest EVM chains
        //     bytes data; // Data payload
        //     EVMTokenAmount[] tokenAmounts; // Token transfers
        //     address feeToken; // Address of feeToken. address(0) means you will send msg.value.
        //     bytes extraArgs; // Populate this with _argsToBytes(EVMExtraArgsV2)
        // }
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(user),
            data: "",
            tokenAmounts: tokenAmounts,
            feeToken: localNetworkDetails.linkAddress,
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 500_000}))
        });

        uint256 fee =
            IRouterClient(localNetworkDetails.routerAddress).getFee(remoteNetworkDetails.chainSelector, message);
        ccipLocalSimulatorFork.requestLinkFromFaucet(user, fee);

        vm.prank(user);
        IERC20(localNetworkDetails.linkAddress).approve(localNetworkDetails.routerAddress, fee);

        vm.prank(user);
        IERC20(localToken).approve(localNetworkDetails.routerAddress, amountToBridge);

        uint256 localBalanceBefore = IERC20(localToken).balanceOf(user);

        vm.prank(user);
        IRouterClient(localNetworkDetails.routerAddress).ccipSend(remoteNetworkDetails.chainSelector, message);
        uint256 localBalanceAfter = IERC20(localToken).balanceOf(user);

        assertEq(localBalanceAfter, localBalanceBefore - amountToBridge);

        // Now receiving message/tokens

        vm.selectFork(remoteFork);
        vm.warp(block.timestamp + 30 minutes);

        uint256 remoteBalanceBefore = IERC20(remoteToken).balanceOf(user);

        ccipLocalSimulatorFork.switchChainAndRouteMessage(remoteFork);

        uint256 remoteBalanceAfter = IERC20(remoteToken).balanceOf(user);

        assertEq(remoteBalanceAfter, remoteBalanceBefore + amountToBridge);
    }

    function testBridgeTokenCrossChain() public {
        vm.selectFork(ethSepoliaFork);
        vm.deal(user, SEND_VALUE);

        vm.prank(user);
        vault.deposit{value: SEND_VALUE}();

        assertEq(ethToken.balanceOf(user), SEND_VALUE);

        bridgeTokens(
            SEND_VALUE,
            ethSepoliaFork,
            arbSepoliaFork,
            ethSepoliaNetworkDetails,
            arbSepoliaNetworkDetails,
            address(ethToken),
            address(arbToken)
        );

        vm.selectFork(arbSepoliaFork);
        vm.warp(block.timestamp + 30 minutes);
        bridgeTokens(
            arbToken.balanceOf(user),
            arbSepoliaFork,
            ethSepoliaFork,
            arbSepoliaNetworkDetails,
            ethSepoliaNetworkDetails,
            address(arbToken),
            address(ethToken)
        );
    }
}
