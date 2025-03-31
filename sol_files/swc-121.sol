pragma solidity ^0.8.0;

contract SignatureReplay {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function verifySignature(bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
        address signer = ecrecover(messageHash, v, r, s);
        return signer == owner;
    }
}