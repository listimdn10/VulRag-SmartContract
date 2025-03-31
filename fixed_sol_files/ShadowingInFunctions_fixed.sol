pragma solidity 0.4.24;

contract ShadowingInFunctions {
    uint public n = 2; // State variable
    uint public x = 3; // State variable

    // Đổi tên biến trả về để tránh trùng với biến trạng thái
    function test1() public view returns (uint result) {
        return n; // Trả về biến trạng thái n
    }

    // Đổi tên biến trả về để tránh trùng với biến trạng thái
    function test2() public view returns (uint result) {
        result = 1; // Sử dụng biến cục bộ result thay vì n
        return result;
    }

    // Đổi tên biến cục bộ để tránh trùng với biến trạng thái
    function test3() public view returns (uint result) {
        uint localN = 4; // Đổi tên biến cục bộ để tránh trùng với n
        return localN + x; // Sử dụng biến trạng thái x
    }
}
