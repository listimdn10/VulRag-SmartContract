pragma solidity ^0.4.25;

contract DosNumber {
    uint numElements = 0;
    uint[] array;

    function insertNnumbers(uint value, uint numbers) public {
        require(numbers > 0, "Number of elements must be greater than zero");

        for (uint i = 0; i < numbers; i++) {
            array.push(value); // Efficiently pushing to the array
            numElements++;
        }
    }

    function clearBatch(uint batchSize) public {
        require(numElements > 1500, "Not enough elements to clear");
        require(batchSize > 0, "Batch size must be greater than zero");

        uint deleteCount = batchSize > numElements ? numElements : batchSize;
        for (uint i = 0; i < deleteCount; i++) {
            array[numElements - 1] = 0;  
            numElements--; 
        }

        if (numElements == 0) {
            array.length = 0;  // Reduce storage size only when safe
        }
    }

    function getLengthArray() public view returns (uint) {
        return numElements;
    }

    function getRealLengthArray() public view returns (uint) {
        return array.length;
    }
}