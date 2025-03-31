pragma solidity ^0.4.22;

contract TwoMappings {

    mapping(uint => uint) m;
    mapping(uint => uint) n;

    constructor() public {
        m[10] = 100;
    }

    function check(uint a) public {
        require(n[a] == 0, "Condition failed");
    }
}