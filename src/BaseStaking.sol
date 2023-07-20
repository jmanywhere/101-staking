// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "openzeppelin/access/Ownable.sol";
import "./interfaces/IBaseStaking.sol";

error BaseStaking__InvalidTime(uint _selectedTime);

contract BaseStaking is IBaseStaking, Ownable {
    struct User {
        uint deposit;
        uint lastClaim;
        uint unblockTime;
    }

    mapping(address => User) public userDeposits;

    uint256 public blockTimer = 180 days;

    function deposit() external payable override {
        userDeposits[msg.sender].deposit += msg.value;
        userDeposits[msg.sender].lastClaim = block.timestamp;
        userDeposits[msg.sender].unblockTime = block.timestamp + blockTimer;
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
        revert("Not implemented");
    }

    function setBlockingTime(uint256 _newTime) external onlyOwner {
        if (_newTime > 2 * 365 days) revert BaseStaking__InvalidTime(_newTime);
        blockTimer = _newTime;
    }
}
