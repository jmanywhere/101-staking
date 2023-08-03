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
    uint256 public prevTokens;

    IWETH public weth;
    uint256 constant MAGNIFIER = 1e12;

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
        prevTokens += msg.value;
    }

    function withdraw() external {
        revert("Not implemented");
    }

    function claimRewards(bool isWETH) external {
        if (!isWETH) revert("Not implemented");
        redistributeRewards();
        User storage user = userDeposits[msg.sender];
        uint256 userReward = (user.deposit * accumulatedRewardsPerToken) /
            MAGNIFIER;
        user.debt = userReward;
        userReward -= user.debt;
        user.lastClaim = block.timestamp;
        weth.transfer(msg.sender, userReward);
        emit ClaimedRewards(msg.sender, userReward);
    }

    function addETHRewards() external payable {
        revert("Not implemented");
    }

    function addWETHRewards() external payable {
        revert("Not implemented");
    }

    function getPendingRewards(address _user) public view returns (uint256) {
        User storage user = userDeposits[_user];
        uint diff = block.timestamp - lastAction;
        if (diff == 0) return 0;
        uint256 reward = diff * emissionsPerSecond();
        reward /= address(this).balance;
        reward =
            ((accumulatedRewardsPerToken + reward) * user.deposit) /
            MAGNIFIER;
        reward -= user.debt;
        return reward;
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

        uint256 timePassed = block.timestamp - lastAction;
        if (timePassed == 0) return;

        uint rewardsPerSecond = emissionsPerSecond();
        uint256 reward = timePassed * rewardsPerSecond;
        reward = reward / prevTokens;
        accumulatedRewardsPerToken = currentRewardsPerToken + reward;
        lastAction = block.timestamp;
    }

    function emissionsPerSecond() public pure returns (uint) {
        return uint256(1 ether * MAGNIFIER) / 100 / 1 days;
    }
}
