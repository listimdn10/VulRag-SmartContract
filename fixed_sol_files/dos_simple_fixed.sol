pragma solidity ^0.4.25;

contract DosOneFunc {
    address[] listAddresses;
    uint public maxBatchSize = 50; // Limit batch processing

    function fillArray(uint batchSize) public returns (bool) {
        require(batchSize > 0 && batchSize <= maxBatchSize, "Invalid batch size");

        if (listAddresses.length < 1500) {
            for (uint i = 0; i < batchSize; i++) {
                listAddresses.push(msg.sender);
            }
            return true;
        }
        return false;
    }

    function clearBatch(uint batchSize) public {
        require(batchSize > 0 && batchSize <= maxBatchSize, "Invalid batch size");
        require(listAddresses.length > 0, "Array is already empty");

        uint deleteCount = batchSize > listAddresses.length ? listAddresses.length : batchSize;
        for (uint i = 0; i < deleteCount; i++) {
            listAddresses[listAddresses.length - 1] = address(0);
            listAddresses.length--;
        }
    }

    function getListSize() public view returns (uint) {
        return listAddresses.length;
    }
}
