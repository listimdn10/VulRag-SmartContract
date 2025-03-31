// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CustomToken {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(uint256 initialSupply) {
        owner = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[owner] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Not enough balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(balanceOf[from] >= value, "Not enough balance");
        require(allowance[from][msg.sender] >= value, "Not approved");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}

contract Crowdsale {
    address payable public wallet;
    CustomToken public token;
    address public owner;

    struct Stage {
        uint256 rate;
        uint256 cap;
        uint256 sold;
    }

    mapping(uint8 => Stage) public stages;
    uint8 public currentStage;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public contributions;

    bool public saleActive = false;

    event TokensPurchased(address indexed buyer, uint256 amount);
    event StageChanged(uint8 newStage);
    event Whitelisted(address indexed investor, bool status);

    constructor(uint256 initialSupply, address payable _wallet) {
        token = new CustomToken(initialSupply);
        wallet = _wallet;
        owner = msg.sender;

        stages[1] = Stage({rate: 1000, cap: 50 ether, sold: 0});
        stages[2] = Stage({rate: 800, cap: 100 ether, sold: 0});
        stages[3] = Stage({rate: 600, cap: 200 ether, sold: 0});

        currentStage = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function whitelistInvestor(
        address investor,
        bool status
    ) external onlyOwner {
        whitelisted[investor] = status;
        emit Whitelisted(investor, status);
    }

    function buyTokens() external payable onlyWhitelisted {
        require(saleActive, "Sale is not active");
        require(currentStage > 0, "No active stage");

        Stage storage stage = stages[currentStage];
        require(stage.sold + msg.value <= stage.cap, "Stage cap reached");

        uint256 tokens = msg.value * stage.rate;
        require(token.balanceOf(address(this)) >= tokens, "Not enough tokens");

        stage.sold += msg.value;
        contributions[msg.sender] += msg.value;

        token.transfer(msg.sender, tokens);
        wallet.transfer(msg.value);

        emit TokensPurchased(msg.sender, tokens);
    }

    function setSaleStatus(bool status) external onlyOwner {
        saleActive = status;
    }

    function nextStage() external onlyOwner {
        require(currentStage < 3, "No more stages");
        currentStage++;
        emit StageChanged(currentStage);
    }

    function withdrawTokens(
        address recipient,
        uint256 amount
    ) external onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "Not enough tokens");
        token.transfer(recipient, amount);
    }
}
