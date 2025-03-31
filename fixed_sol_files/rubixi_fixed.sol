pragma solidity ^0.4.22;

contract Rubixi {
    uint private balance = 0;
    uint private collectedFees = 0;
    uint private feePercent = 10;
    uint private pyramidMultiplier = 300;
    uint private payoutOrder = 0;

    address private creator;

    constructor() public {
        creator = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == creator);
        _;
    }

    struct Participant {
        address etherAddress;
        uint payout;
    }

    Participant[] private participants;

    function() public payable {
        init();
    }

    function init() private {
        if (msg.value < 1 ether) {
            collectedFees += msg.value;
            return;
        }

        uint _fee = feePercent;
        if (msg.value >= 50 ether) _fee /= 2;

        addPayout(_fee);
    }

    function addPayout(uint _fee) private {
        participants.push(Participant(msg.sender, (msg.value * pyramidMultiplier) / 100));

        if (participants.length == 10) pyramidMultiplier = 200;
        else if (participants.length == 25) pyramidMultiplier = 150;

        balance += (msg.value * (100 - _fee)) / 100;
        collectedFees += (msg.value * _fee) / 100;

        while (balance > participants[payoutOrder].payout) {
            uint payoutToSend = participants[payoutOrder].payout;
            participants[payoutOrder].etherAddress.transfer(payoutToSend);

            balance -= participants[payoutOrder].payout;
            payoutOrder += 1;
        }
    }

    function collectAllFees() public onlyOwner {
        require(collectedFees > 0);
        creator.transfer(collectedFees);
        collectedFees = 0;
    }

    function collectFeesInEther(uint _amt) public onlyOwner {
        _amt *= 1 ether;
        if (_amt > collectedFees) collectAllFees();

        require(collectedFees > 0);
        creator.transfer(_amt);
        collectedFees -= _amt;
    }

    function collectPercentOfFees(uint _pcent) public onlyOwner {
        require(collectedFees > 0 && _pcent <= 100);

        uint feesToCollect = (collectedFees * _pcent) / 100;
        creator.transfer(feesToCollect);
        collectedFees -= feesToCollect;
    }

    function changeOwner(address _owner) public onlyOwner {
        creator = _owner;
    }

    function changeMultiplier(uint _mult) public onlyOwner {
        require(_mult <= 300 && _mult >= 120);
        pyramidMultiplier = _mult;
    }

    function changeFeePercentage(uint _fee) public onlyOwner {
        require(_fee <= 10);
        feePercent = _fee;
    }
}
