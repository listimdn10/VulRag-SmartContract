/*
 * @source: https://github.com/sigp/solidity-security-blog#visibility
 * @author: SigmaPrime
 * Modified by Gerhard Wagner
 */

pragma solidity ^0.4.24;

contract HashForEther {

 function withdrawWinnings() public {
 
 require(uint32(msg.sender) == 0);
 _sendWinnings();
 }

 function _sendWinnings() internal{
 msg.sender.transfer(this.balance);
 }
}
