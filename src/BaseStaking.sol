// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "openzeppelin/access/Ownable.sol";
import "./interfaces/IBaseStaking.sol";
import "./interfaces/IWETH.sol";

import "forge-std/console.sol";

error BaseStaking__InvalidTime(uint _selectedTime);
error BaseStaking__InvalidDepositAmount();

contract BaseStaking is IBaseStaking, Ownable {
    struct User {
        uint deposit;
        uint lastClaim;
        uint unblockTime;
        uint debt;
    }

    mapping(address => User) public userDeposits;

    uint256 public blockTimer = 180 days;
    uint256 public totalRewardsToGive;
    uint256 public lastAction;
    uint256 public accumulatedRewardsPerToken;

    IWETH public weth;

    constructor(address _weth) {
        lastAction = block.timestamp;
        weth = IWETH(_weth);
    }

    function deposit() external payable override {
        if (msg.value == 0) revert BaseStaking__InvalidDepositAmount();

        redistributeRewards();

        userDeposits[msg.sender].deposit += msg.value;
        userDeposits[msg.sender].lastClaim = block.timestamp;
        userDeposits[msg.sender].unblockTime = block.timestamp + blockTimer;

        userDeposits[msg.sender].debt =
            accumulatedRewardsPerToken *
            block.timestamp;

        console.log("Data ", msg.value, block.timestamp);
    }

    function withdraw() external {
        revert("Not implemented");
    }

    function claimRewards(bool isWETH) external {
        revert("Not implemented");
    }

    function addETHRewards() external payable {
        revert("Not implemented");
    }

    function addWETHRewards() external {
        revert("Not implemented");
    }

    function getPendingRewards(address _user) external view returns (uint256) {
        revert("Not implemented");
    }

    function getUserAPY(address _user) external view returns (uint256) {
        revert("Not implemented");
    }

    function addWETHRewards(uint _transferAmount) external {
        totalRewardsToGive += _transferAmount;
        weth.transferFrom(msg.sender, address(this), _transferAmount);
    }

    function setBlockingTime(uint256 _newTime) external onlyOwner {
        if (_newTime > 2 * 365 days) revert BaseStaking__InvalidTime(_newTime);
        blockTimer = _newTime;
    }

    function redistributeRewards() internal {
        uint currentRewardsPerToken = accumulatedRewardsPerToken;

        if (block.timestamp - lastAction == 0) return;

        uint256 timePassed = block.timestamp - lastAction;
        uint rewardsPerSecond = (totalRewardsToGive * 1e12) / 100 / 1 days;
        uint256 reward = timePassed * rewardsPerSecond;
        reward = reward / address(this).balance;
        accumulatedRewardsPerToken = currentRewardsPerToken + reward;
    }
}
