pragma solidity 0.4.24;

contract VulnerableRefunder {
    address[] private recipients; // Changed to private to control access
    mapping(address => uint) public balances;

    constructor() public {
        // Add some example recipients
        recipients.push(0x1111111111111111111111111111111111111111);
        recipients.push(0x2222222222222222222222222222222222222222);
        recipients.push(0x3333333333333333333333333333333333333333);
    }

    // Allow deposits to fund the contract
    function deposit() public payable {
        require(msg.value > 0, "Must send ETH to deposit");
    }

    // Vulnerable function: pushes payments in a loop (SWC-113)
    function distributePayments() public {
        // Store initial balances
        for (uint i = 0; i < recipients.length; i++) {
            balances[recipients[i]] = 1 ether;
        }

        // Distribute payments - still vulnerable to SWC-113
        for (uint j = 0; j < recipients.length; j++) {
            require(
                recipients[j].send(balances[recipients[j]]),
                "Payment failed"
            );
            balances[recipients[j]] = 0;
        }
    }

    // Function to add new recipient
    function addRecipient(address newRecipient) public {
        recipients.push(newRecipient);
    }

    // Safe getter for recipients with bounds checking
    function getRecipient(uint index) public view returns (address) {
        require(index < recipients.length, "Index out of bounds");
        return recipients[index];
    }

    // Getter for recipients length
    function getRecipientsCount() public view returns (uint) {
        return recipients.length;
    }
}