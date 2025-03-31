/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 */
pragma solidity ^0.4.22;

contract ShaOfSha2Mappings{

 mapping(bytes32=>uint) m;
 mapping(bytes32=>uint) n;

 constructor(){
 m[keccak256(abi.encode("AAA", msg.sender))] = 100;
 }

 function check(address a) public {
 require(n[keccak256(abi.encode("BBB", a))] == 0, "Mapping value is not zero!");
 }

}
