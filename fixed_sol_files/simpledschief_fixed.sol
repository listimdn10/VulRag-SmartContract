/*
 * @source: https://forum.zeppelin.solutions/t/using-automatic-analysis-tools-with-makerdao-contracts/1021/3
 * Author: Vera Bogdanich Espina / Zeppelin Solutions
 *
 * A simplified version of the MakerDAO DSChief contract.
 * Tools should output the correct transaction trace (see source link).
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.22;

contract SimpleDSChief {
    mapping(bytes32 => address) public slates;
    mapping(address => bytes32) public votes;
    mapping(address => uint256) public approvals;
    mapping(address => uint256) public deposits;

    function lock(uint wad) public {
        deposits[msg.sender] = add(deposits[msg.sender], wad);
        addWeight(wad, votes[msg.sender]);
    }

    function free(uint wad) public {
        deposits[msg.sender] = sub(deposits[msg.sender], wad);
        subWeight(wad, votes[msg.sender]);
    }

    function voteYays(address yay) public returns (bytes32) {
        bytes32 slate = etch(yay);
        voteSlate(slate);
        return slate;
    }

    function etch(address yay) public returns (bytes32 slate) {
        bytes32 hash = keccak256(abi.encodePacked(yay));
        slates[hash] = yay;
        return hash;
    }

    function voteSlate(bytes32 slate) public {
        uint weight = deposits[msg.sender];
        subWeight(weight, votes[msg.sender]);
        votes[msg.sender] = slate;
        addWeight(weight, votes[msg.sender]);
    }

    function addWeight(uint weight, bytes32 slate) internal {
        address yay = slates[slate];
        approvals[yay] = add(approvals[yay], weight);
    }

    function subWeight(uint weight, bytes32 slate) internal {
        address yay = slates[slate];
        approvals[yay] = sub(approvals[yay], weight);
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "Addition overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "Subtraction underflow");
    }

    function checkAnInvariant() public {
        bytes32 senderSlate = votes[msg.sender];
        address option = slates[senderSlate];
        uint256 senderDeposit = deposits[msg.sender];
        require(approvals[option] >= senderDeposit);
    }
}