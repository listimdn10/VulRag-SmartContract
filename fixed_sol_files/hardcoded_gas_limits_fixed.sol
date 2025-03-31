/*
 * @author: Updated Solidity Code
 * @fix: Removed transfer() and send(), replaced with .call() with require(success, ...)
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.6.4;

interface ICallable {
    function callMe() external;
}

contract HardcodedNotGood {
    address payable private _callable = 0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa;
    ICallable private callable = ICallable(_callable);

    constructor() public payable {}

    function doTransfer(uint256 amount) public {
        (bool success, ) = _callable.call{value: amount}(""); // ✅ Use .call() instead of transfer/send
        require(success, "Transfer failed");
    }

    function doSend(uint256 amount) public {
        (bool success, ) = _callable.call{value: amount}(""); // ✅ Check return value
        require(success, "Send failed");
    }

    function callLowLevel() public {
        (bool success, ) = _callable.call{gas: 10000, value: 0}(""); // ✅ Check return value
        require(success, "Low-level call failed");
    }

    function callWithArgs() public {
        (bool success, ) = address(callable).call{gas: 10000}(
            abi.encodeWithSignature("callMe()")
        ); // ✅ Safe low-level call
        require(success, "callWithArgs failed");
    }
}
