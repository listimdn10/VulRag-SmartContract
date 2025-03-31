pragma solidity 0.4.25;

contract ReturnValue {

 function callchecked(address callee) public {
 require(callee.call(), "Call failed");
 }

 function callnotchecked(address callee) public {
 bool success = callee.call();
 require(success, "Call failed");
 }
}
