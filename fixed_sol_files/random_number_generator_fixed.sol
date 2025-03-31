// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subscriptionId,
        uint16 requestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);
}

abstract contract VRFConsumerBaseV2 {
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal virtual;

    address private immutable vrfCoordinator;

    constructor(address _vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
    }
}

contract RandomNumberGenerator is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 subscriptionId;
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    bytes32 keyHash =
        0x6c3699283bda56ad74f6b855546325b68d482e983852a3a5bde69e3ea85e90b3;
    // Replace with actual keyHash for Chainlink VRF
    uint16 requestConfirmations = 3;
    uint32 callbackGasLimit = 100000;
    uint32 numWords = 1;

    uint256 public randomResult;

    constructor(uint64 _subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        subscriptionId = _subscriptionId;
    }

    function requestRandomNumber() external {
        COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        randomResult = randomWords[0];
    }

    function getRandomNumber(uint max) external view returns (uint256) {
        require(randomResult > 0, "Random number not generated yet");
        return (randomResult % max) + 1;
    }
}
