pragma solidity ^0.4.25;

library SafeMath {

 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 if (a == 0) {
 return 0;
 }
 uint256 c = a * b;
 require(c / a == b);
 return c;
 }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b > 0);
 return a / b;
 }

 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b <= a);
 return a - b;
 }

 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a);
 return c;
 }

 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b != 0);
 return a % b;
 }
}

contract TypoSafeMath {

 using SafeMath for uint256;
 uint256 public numberOne = 1;
 bool public win = false;

 function addOne() public {
 numberOne += 1;
 }

 function addOneCorrect() public {
 numberOne += 1;
 }

 function addOneSafeMath() public {
 numberOne = numberOne.add(1);
 }

 function iWin() public {
 if(!win && numberOne > 3) {
 win = true;
 }
 }
}
