/*
 * @source: ChainSecurity
 * @author: Anton Permenev
 */

pragma solidity ^0.4.25;

contract ConstructorCreate {
    B b = new B();  

    function check() public {
        require(b.foo() == 10);  
    }
}

contract B {
    function foo() public returns(uint) {
        return 11;  
    }
}
