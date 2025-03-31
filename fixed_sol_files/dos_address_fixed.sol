pragma solidity ^0.4.25;

contract DosGas {
    address[] creditorAddresses;
    bool win = false;

    function emptyCreditors(uint batchSize) public {
        require(batchSize > 0, "Batch size must be greater than zero");

        uint length = creditorAddresses.length;
        if (length > 1500) {
            uint deleteCount = batchSize > length ? length : batchSize;
            for (uint i = 0; i < deleteCount; i++) {
                creditorAddresses[length - 1] = address(0);  
                length--; 
            }

            creditorAddresses.length = length;

            if (creditorAddresses.length == 0) {
                win = true;
            }
        }
    }

    function addCreditors(uint batchSize) public returns (bool) {
        require(batchSize > 0, "Batch size must be greater than zero");

        for (uint i = 0; i < batchSize; i++) {
            creditorAddresses.push(msg.sender);
        }
        return true;
    }

    function iWin() public view returns (bool) {
        return win;
    }

    function numberCreditors() public view returns (uint) {
        return creditorAddresses.length;
    }
}
