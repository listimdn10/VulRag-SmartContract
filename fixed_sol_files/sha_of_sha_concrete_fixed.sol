/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 * Fixed version replacing assert() with require().
 */
pragma solidity ^0.4.22;

contract ShaOfShaConcrete {

    mapping(bytes32 => uint) m;
    uint b;

    constructor() public {
        b = 1;
    }

    function check(uint x) public {
        require(m[keccak256(abi.encodePacked(x, "B"))] == 0, "Condition failed");
    }
}