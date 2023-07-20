// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/BaseStaking.sol";

contract BaseStakingTest is Test {
    BaseStaking staking;
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        // weth = new WETH();
        staking = new BaseStaking();
    }

    function test_change_blocking_time() public {
        staking.setBlockingTime(1000);
        assertEq(staking.blockTimer(), 1000);
    }
}
