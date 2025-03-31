/*
 * @source: https://github.com/ConsenSys/evm-analyzer-benchmark-suite
 * @author: Suhabe Bugrara
 * @fix: Prevent integer underflow in run() function
 */

pragma solidity ^0.4.23;

library SafeMath {
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b <= a, "Integer underflow");
 return a - b;
 }
}

contract IntegerOverflowMultiTxOneFuncInfeasible {
 using SafeMath for uint256;

 uint256 private initialized = 0;
 uint256 public count = 1;

 function run(uint256 input) public {
 if (initialized == 0) {
 return;
 }

 count = count.sub(input);
 }
}
