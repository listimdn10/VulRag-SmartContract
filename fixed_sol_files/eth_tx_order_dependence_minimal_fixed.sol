pragma solidity ^0.4.24;

contract EthTxOrderDependenceMinimal {
    address public owner;
    bool public claimed;
    uint public reward;

    mapping(address => uint) public pendingRewards;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Đổi tên hàm khởi tạo thành tên hợp đồng (dành cho Solidity ^0.4.x)
    function EthTxOrderDependenceMinimal() public {
        owner = msg.sender;
    }

    function setReward() public payable onlyOwner {
        require(!claimed, "Reward already claimed");

        // Refund the previous reward to the owner before updating
        if (reward > 0) {
            pendingRewards[owner] += reward;
        }

        reward = msg.value;
    }

    function claimReward(uint256 submission) public {
        require(!claimed, "Reward already claimed");
        require(submission < 10, "Invalid submission");

        claimed = true;
        pendingRewards[msg.sender] += reward;
    }

    function withdraw() public {
        uint amount = pendingRewards[msg.sender];
        require(amount > 0, "No funds to withdraw");

        // Reset the pending reward before transferring to prevent reentrancy
        pendingRewards[msg.sender] = 0;

        // Use call instead of transfer for better gas handling
        (bool success, ) = msg.sender.call.value(amount)("");
        require(success, "Transfer failed");
    }
}
