/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 */
pragma solidity ^0.4.22;

contract RuntimeCreateUserInput {
    function check(uint x) public {
        B b = new B(x);
        require(b.foo() == 10, "Value must be 10!");
    }
}

contract B{

 uint x_;
 constructor(uint x) public {
 x_ = x;
 }

 function foo() public returns(uint){
 return x_;
 }

}
