pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
 if (a == 0) return 0;
 uint256 c = a * b;
 require(c / a == b, "Multiplication overflow");
 return c;
 }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b > 0, "Division by zero");
 uint256 c = a / b;
 return c;
 }

 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
 require(b <= a, "Subtraction underflow");
 return a - b;
 }

 function add(uint256 a, uint256 b) internal pure returns (uint256) {
 uint256 c = a + b;
 require(c >= a, "Addition overflow");
 return c;
 }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 */
contract ERC20Basic {
 uint256 public totalSupply;
 function balanceOf(address who) public view returns (uint256);
 function transfer(address to, uint256 value) public returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
 using SafeMath for uint256;

 mapping(address => uint256) balances;

 function transfer(address _to, uint256 _value) public returns (bool) {
 require(_to != address(0), "Invalid address");
 require(_value > 0 && _value <= balances[msg.sender], "Invalid transfer value");

 balances[msg.sender] = balances[msg.sender].sub(_value);
 balances[_to] = balances[_to].add(_value);
 emit Transfer(msg.sender, _to, _value);
 return true;
 }

 function balanceOf(address _owner) public view returns (uint256 balance) {
 return balances[_owner];
 }
}

/**
 * @title ERC20 interface
 */
contract ERC20 is ERC20Basic {
 function allowance(address owner, address spender) public view returns (uint256);
 function transferFrom(address from, address to, uint256 value) public returns (bool);
 function approve(address spender, uint256 value) public returns (bool);
 event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 */
contract StandardToken is ERC20, BasicToken {
 mapping (address => mapping (address => uint256)) internal allowed;

 function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
 require(_to != address(0), "Invalid address");
 require(_value > 0 && _value <= balances[_from], "Invalid transfer value");
 require(_value <= allowed[_from][msg.sender], "Allowance exceeded");

 balances[_from] = balances[_from].sub(_value);
 balances[_to] = balances[_to].add(_value);
 allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
 emit Transfer(_from, _to, _value);
 return true;
 }

 function approve(address _spender, uint256 _value) public returns (bool) {
 require(_spender != address(0), "Invalid address");
 require(allowed[msg.sender][_spender] == 0 || _value == 0, "Approve race condition");
 allowed[msg.sender][_spender] = _value;
 emit Approval(msg.sender, _spender, _value);
 return true;
 }

 function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
 return allowed[_owner][_spender];
 }
}

/**
 * @title Ownable
 */
contract Ownable {
 address public owner;

 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 constructor() public {
 owner = msg.sender;
 }

 modifier onlyOwner() {
 require(msg.sender == owner, "Caller is not the owner");
 _;
 }

 function transferOwnership(address newOwner) public onlyOwner {
 require(newOwner != address(0), "Invalid address");
 emit OwnershipTransferred(owner, newOwner);
 owner = newOwner;
 }
}

/**
 * @title Pausable
 */
contract Pausable is Ownable {
 event Pause();
 event Unpause();

 bool public paused = false;

 modifier whenNotPaused() {
 require(!paused, "Contract is paused");
 _;
 }

 modifier whenPaused() {
 require(paused, "Contract is not paused");
 _;
 }

 function pause() public onlyOwner whenNotPaused {
 paused = true;
 emit Pause();
 }

 function unpause() public onlyOwner whenPaused {
 paused = false;
 emit Unpause();
 }
}

/**
 * @title Pausable token
 */
contract PausableToken is StandardToken, Pausable {
 function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
 return super.transfer(_to, _value);
 }

 function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
 return super.transferFrom(_from, _to, _value);
 }

 function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
 return super.approve(_spender, _value);
 }

 function batchTransfer(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
 uint256 cnt = _receivers.length;
 uint256 amount = uint256(cnt).mul(_value);
 require(cnt > 0 && cnt <= 20, "Invalid receiver count");
 require(_value > 0 && balances[msg.sender] >= amount, "Insufficient balance");

 balances[msg.sender] = balances[msg.sender].sub(amount);
 for (uint256 i = 0; i < cnt; i++) {
 balances[_receivers[i]] = balances[_receivers[i]].add(_value);
 emit Transfer(msg.sender, _receivers[i], _value);
 }
 return true;
 }
}

/**
 * @title Bec Token
 */
contract BecToken is PausableToken {
 string public name = "BeautyChain";
 string public symbol = "BEC";
 string public version = "1.0.0";
 uint8 public decimals = 18;

 constructor() public {
 totalSupply = 7000000000 * (10**uint256(decimals));
 balances[msg.sender] = totalSupply;
 }

 function() external {
 revert("Fallback function not allowed");
 }
}
