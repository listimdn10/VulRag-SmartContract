/*
 * @source: https://github.com/ConsenSys/evm-analyzer-benchmark-suite
 * @author: Suhabe Bugrara
 */

pragma solidity ^0.4.19;

contract AssertMultiTx2 {
 uint256 private param;

 function AssertMultiTx2(uint256 _param) public {
 param = 0;
 }

 function run() public {
 require(param > 0);
 }

 function set(uint256 _param) public {
 param = _param;
 }

}
