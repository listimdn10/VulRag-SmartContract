


pragma solidity ^0.4.16;

contract IntegerOverflowMappingSym1 {
 mapping(uint256 => uint256) map;

 function init(uint256 k, uint256 v) public {
 map[k] = sub(map[k], v);
 }

 
 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b <= a);
 return a - b;
 }
}
