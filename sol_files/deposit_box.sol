pragma solidity ^0.5.0;

contract DepositBox {
 mapping(address => uint) balance;

 
 function deposit(uint amount) public payable {
 require(msg.value == amount, 'incorrect amount');
 
 balance[msg.sender] == amount;
 }
}
