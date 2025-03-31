/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 * Fixed version replacing assert() with require().
 */
pragma solidity ^0.4.22;

contract ShaOfShaCollission {

    mapping(bytes32 => uint) m;

    function set(uint x) public {
        m[keccak256(abi.encodePacked("A", x))] = 1;
    }

    function check(uint x) public {
        require(m[keccak256(abi.encodePacked(x, "B"))] == 0, "Condition failed");
    }
}