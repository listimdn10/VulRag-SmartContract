/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 * Fixed version: assert() replaced with require()
 */

pragma solidity ^0.4.22;

contract ContructorCreateModifiable {
 B b = new B(10);

 function check() public {
 require(b.foo() == 10, "Value mismatch!");
 }
}

contract B {
 uint x_;
 constructor(uint x) public {
 x_ = x;
 }

 function foo() public returns(uint) {
 return x_;
 }

 function set_x(uint x) public {
 x_ = x;
 }
}
