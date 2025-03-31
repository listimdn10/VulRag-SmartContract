/*
 * @source: TrailofBits workshop at TruffleCon 2018
 * @author: Josselin Feist (adapted for SWC by Bernhard Mueller)
 */
pragma solidity ^0.4.22;

contract Token {

 mapping(address => uint) public balances;
 
 function airdrop() public {
 balances[msg.sender] = 1000;
 }

 function consume() public {
 require(balances[msg.sender] > 0);
 balances[msg.sender] -= 1;
 }

 function backdoor() public {
 balances[msg.sender] += 1;
 }

 function test_invariants() public {
 require(balances[msg.sender] <= 1000, "Invariant violated");
 }
}
