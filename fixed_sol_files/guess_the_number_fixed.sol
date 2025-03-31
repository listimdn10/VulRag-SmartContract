pragma solidity ^0.5.0;

contract GuessTheNumber {
    uint private _secretNumber;
    address payable private _owner;
    
    event Success(string);
    event WrongNumber(string);

    constructor(uint secretNumber) payable public {
        require(secretNumber <= 10, "Secret number must be between 0 and 10");
        _secretNumber = secretNumber;
        _owner = msg.sender;
    }

    function getValue() public view returns (uint) {
        return address(this).balance;
    }

    function guess(uint n) public payable {
        require(msg.value == 1 ether, "You must send exactly 1 ether");

        uint prize = address(this).balance;
        checkAndTransferPrize(n, prize, msg.sender);
    }

    function checkAndTransferPrize(uint n, uint prize, address payable guesser) internal {
        if (n == _secretNumber) {
            guesser.transfer(prize);
            emit Success("You guessed the correct number!");
        } else {
            emit WrongNumber("You've made an incorrect guess!");
        }
    }

    function kill() public {
        require(msg.sender == _owner, "Only the owner can self-destruct the contract");
        selfdestruct(_owner);
    }
}