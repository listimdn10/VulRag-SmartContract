pragma solidity ^0.8.0;

contract SignatureReplay {
    address public owner;
    mapping(bytes32 => bool) public usedHashes;

    constructor() {
        owner = msg.sender;
    }

    function verifySignature(bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public returns (bool) {
        require(!usedHashes[messageHash], "Replay attack detected!");
        bytes32 prefixedHash = keccak256(abi.encodePacked(address(this), messageHash));
        address signer = ecrecover(prefixedHash, v, r, s);
        if (signer == owner) {
            usedHashes[messageHash] = true;
            return true;
        }
        return false;
    }
}