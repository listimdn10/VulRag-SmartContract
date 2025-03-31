pragma solidity ^0.4.24;

contract Map {
    address public owner;
    mapping(uint256 => uint256) private map;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function set(uint256 key, uint256 value) public {
        map[key] = value;
    }

    function get(uint256 key) public view returns (uint256) {
        return map[key];
    }

    function withdraw() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
}
