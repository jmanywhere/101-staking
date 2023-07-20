// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBaseStaking {
    /**
     * @notice Deposit native tokens into staking pool
     * @dev if user is validator, 25% APY else 10% APY
     * @dev if user deposits 200k then they count as a validator
     */
    function deposit() external payable;

    /**
     * @notice withdraw native tokens out of the staking pool
     */
    function withdraw() external;

    /**
     * @notice Claim rewards
     * @param isWETH verify if token is WETH
     */
    function claimRewards(bool isWETH) external;

    /**
     * @notice Add WETH to the staking pool
     * @param _transferAmount specifies the transfer amount
     */
    function addWETHRewards(uint _transferAmount) external;

    /**
     * @notice Add ETH into the staking pool
     */
    function addETHRewards() external payable;

    /**
     * @notice get pending rewards per address
     * @param _user address of the user to check
     */
    function getPendingRewards(address _user) external view returns (uint256);

    /**
     * @notice get the current APY for a particular user in the pool;
     * @param _user address of the user to check
     * @return the current APY for a particular user in the pool;
     *  If user is a validator 25%
     *  if user is a holder 10%
     */
    function getUserAPY(address _user) external view returns (uint256);

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount, bool isWETH);
    event AddedRewards(uint256 amount, bool isWETH);
}
