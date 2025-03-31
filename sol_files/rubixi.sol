pragma solidity ^0.4.22;

contract Rubixi {
    uint private balance = 0;
    uint private collectedFees = 0;
    uint private feePercent = 10;
    uint private pyramidMultiplier = 300;
    uint private payoutOrder = 0;

    address private creator;

    function DynamicPyramid() public {
        creator = msg.sender;
    }

    modifier onlyowner {
        if (msg.sender == creator) _;
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
            participants[payoutOrder].etherAddress.send(payoutToSend);

            balance -= participants[payoutOrder].payout;
            payoutOrder += 1;
        }
    }

    function collectAllFees() public onlyowner {
        if (collectedFees == 0) revert();
        creator.send(collectedFees);
        collectedFees = 0;
    }

    function collectFeesInEther(uint _amt) public onlyowner {
        _amt *= 1 ether;
        if (_amt > collectedFees) collectAllFees();

        if (collectedFees == 0) revert();
        creator.send(_amt);
        collectedFees -= _amt;
    }

    function collectPercentOfFees(uint _pcent) public onlyowner {
        if (collectedFees == 0 || _pcent > 100) revert();

        uint feesToCollect = collectedFees / 100 * _pcent;
        creator.send(feesToCollect);
        collectedFees -= feesToCollect;
    }

    function changeOwner(address _owner) public onlyowner {
        creator = _owner;
    }

    function changeMultiplier(uint _mult) public onlyowner {
        if (_mult > 300 || _mult < 120) revert();
        pyramidMultiplier = _mult;
    }

    function changeFeePercentage(uint _fee) public onlyowner {
        if (_fee > 10) revert();
        feePercent = _fee;
    }
}
