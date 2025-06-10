// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

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

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title Random Number Generator using Chainlink VRF(Verifiable Random Function) V2.5
 * @author Mohammed Muzammil
 * @notice Request secure random number from Chainlink VRF
 * @dev Uses VRFConsumerBaseV2Plus and VRFV2PlusClient to integrate with Chainlink VRF
 */
contract RandomNumberGenerator is VRFConsumerBaseV2Plus {
    // ERRORS

    // STATE VARIABLES
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private constant CALLBACK_GAS_LIMIT = 40000;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    mapping(address user => uint256 randomNumber) private s_randomNumbers;
    mapping(uint256 requestId => address user) private s_requestIdToUser;

    // EVENTS
    event RandomNumberRequested(uint256 indexed requestId, address indexed user);
    event RandomNumberFullFilled(address indexed user, uint256 indexed randomNumber);

    // MODIFIERS

    // FUNCTIONS
    /**
     * @notice Initialize the RandomNumberGenerator contract
     * @param coordinator The VRF Coordinator contract address
     * @param _keyHash The gas Lane key Hash
     * @param _subId The Chainlink VRF Subscription ID
     */
    constructor(address coordinator, bytes32 _keyHash, uint256 _subId) VRFConsumerBaseV2Plus(coordinator) {
        i_keyHash = _keyHash;
        i_subscriptionId = _subId;
    }

    // EXTERNAL FUNCTIONS
    /**
     * @notice Request a secure random number from chainlink VRF
     * @dev Stores request Id in mapping s_requestIdToUser
     */
    function requestRandomNumber() external {
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: CALLBACK_GAS_LIMIT,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
        s_requestIdToUser[requestId] = msg.sender;

        emit RandomNumberRequested(requestId, msg.sender);
    }

    // PUBLIC FUNCTIONS

    // INTERNAL FUNCTIONS
    /**
     * @notice Callback function called by VRF nodes with the random numbers
     * @param requestId The request Id of the VRF request
     * @param randomWords The array(uint256) random numbers returned by chainlink VRF
     */
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 randomNumber = randomWords[0];
        address user = s_requestIdToUser[requestId];
        s_randomNumbers[user] = randomNumber;
        emit RandomNumberFullFilled(user, randomNumber);
    }

    // PRIVATE FUNCTIONS

    // VIEW AND PURE FUNCTION
    /**
     * @notice Returns the last random number assigned to the caller
     * @return The random number assigned to the caller
     */
    function getMyRandomNumber(address user) external view returns (uint256) {
        return s_randomNumbers[user];
    }
}
