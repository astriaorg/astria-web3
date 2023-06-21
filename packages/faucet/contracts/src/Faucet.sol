pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

contract Faucet {

    IERC20 public tokenInstance;
    address public owner;
    uint256 public tokenAmount = 10 ether;
    uint256 public waitTime = 30 minutes;
    mapping(address => uint256) public lastAccessTime;

    event TokensRequested(address indexed user, uint256 amount);
    event TokensReceived(address indexed user, uint256 amount);
    event FaucetToppedUp(uint256 amount);
    event EmergencyWithdrawal(uint256 amount);

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    constructor(address _tokenInstance) public {
        require(_tokenInstance != address(0));
        tokenInstance = IERC20(_tokenInstance);
        owner = msg.sender;
    }

    function setTokenAmount(uint256 _tokenAmount) public onlyOwner {
        tokenAmount = _tokenAmount;
    }

    function setWaitTime(uint256 _waitTime) public onlyOwner {
        waitTime = _waitTime;
    }

    function requestTokens() public {
        require(isAccessingAfterWaitTime(msg.sender), "You have to wait 30 minutes from your last withdrawal before you can withdraw again.");
        require(isContractFunded(), "Not enough tokens in the faucet.");

        tokenInstance.transfer(msg.sender, tokenAmount);
        lastAccessTime[msg.sender] = block.timestamp + waitTime;

        emit TokensRequested(msg.sender, tokenAmount);
    }

    function topUpTokens(uint256 amount) public onlyOwner {
        require(isSenderFunded(amount), "Not enough token balance for amount given.");
        tokenInstance.transferFrom(msg.sender, address(this), amount);

        emit FaucetToppedUp(amount);
    }

    function emergencyWithdraw() public onlyOwner {
        uint256 balance = tokenInstance.balanceOf(address(this));
        tokenInstance.transfer(owner, balance);
        emit EmergencyWithdrawal(balance);
    }

    function isAccessingAfterWaitTime(address _address) public view returns (bool) {
        if (lastAccessTime[_address] == 0) {
            return true;
        } else if (block.timestamp >= lastAccessTime[_address]) {
            return true;
        }
        return false;
    }

    function isContractFunded() public view returns (bool) {
        return tokenInstance.balanceOf(address(this)) >= tokenAmount;
    }

    function isSenderFunded(uint256 amount) public view returns (bool) {
        return tokenInstance.balanceOf(msg.sender) >= amount;
    }
}
