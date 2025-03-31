pragma solidity ^0.8.0;

contract SecureContract {
    mapping(address => bool) public authorizedUsers;

    function verifySignature(address user) public {
        require(user == msg.sender, "Unauthorized user");
        authorizedUsers[user] = true;
    }
}