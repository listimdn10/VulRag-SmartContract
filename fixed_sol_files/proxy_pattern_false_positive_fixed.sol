pragma solidity ^0.4.24;

contract Proxy {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }
}