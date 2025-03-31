pragma solidity ^0.8.0;

contract SecureContract {
    mapping(address => bool) public authorizedUsers;

    function verifySignature(bytes32 hash, bytes memory signature) public {
        address signer = recoverSigner(hash, signature);
        require(signer != address(0), "Invalid signature");
        authorizedUsers[signer] = true;
    }

    function recoverSigner(bytes32 hash, bytes memory signature) internal pure returns (address) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature version");

        return ecrecover(hash, v, r, s);
    }
}