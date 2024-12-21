// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EducationDAO {

    string public name = "EducationDAO Governance Token";
    string public symbol = "EDU";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public contributions;
    mapping(address => uint256) public lastClaimed;
    
    uint256 public rewardRate = 1e18;  // Tokens rewarded per contribution
    uint256 public claimInterval = 30 days;  // Minimum interval to claim tokens again
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Contribution(address indexed user, uint256 contributionAmount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this.");
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[owner] = totalSupply;
    }

    // Add contribution for a user
    function addContribution(address _user, uint256 _amount) external {
        require(_amount > 0, "Contribution must be positive.");
        
        contributions[_user] += _amount;
        emit Contribution(_user, _amount);
    }

    // Claim governance tokens based on the contribution
    function claimTokens() external {
        uint256 lastClaim = lastClaimed[msg.sender];
        require(block.timestamp >= lastClaim + claimInterval, "Claim interval has not passed.");
        
        uint256 reward = contributions[msg.sender] * rewardRate / 1e18;
        require(reward > 0, "No reward available.");
        
        lastClaimed[msg.sender] = block.timestamp;
        balanceOf[owner] -= reward;
        balanceOf[msg.sender] += reward;
        
        emit Transfer(owner, msg.sender, reward);
    }

    // Transfer tokens between users
    function transfer(address _to, uint256 _amount) external returns (bool success) {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance.");
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    
    // Owner can withdraw any remaining tokens
    function withdrawTokens(uint256 _amount) external onlyOwner {
        require(balanceOf[owner] >= _amount, "Insufficient balance.");
        balanceOf[owner] -= _amount;
        payable(owner).transfer(_amount);
    }

    // Function to change the reward rate (only by the owner)
    function setRewardRate(uint256 _newRate) external onlyOwner {
        rewardRate = _newRate;
    }
}
