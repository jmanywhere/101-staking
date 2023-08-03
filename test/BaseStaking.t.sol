// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/BaseStaking.sol";
import "../src/WETH.sol";

contract BaseStakingTest is Test {
    BaseStaking staking;
    WETH9 weth;
    address owner = makeAddr("owner");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        weth = new WETH9();
        vm.deal(owner, 1000 ether);
        vm.deal(user1, 1000 ether);
        vm.deal(user2, 1000 ether);
        vm.deal(user3, 1000 ether);
        vm.prank(owner);
        weth.deposit{value: 100 ether}();

        staking = new BaseStaking(address(weth));

        vm.startPrank(owner);
        weth.approve(address(staking), 10000 ether);
        staking.addWETHRewards(10 ether);
        vm.stopPrank();
    }

    function test_change_blocking_time() public {
        staking.setBlockingTime(1000);
        assertEq(staking.blockTimer(), 1000);
    }

    function test_deposit() public {
        vm.expectRevert();
        staking.deposit();

        vm.prank(user1);
        staking.deposit{value: 1 ether}();

        (uint deposits, uint depositTime, uint unblockTime, uint debt) = staking
            .userDeposits(user1);
        assertEq(deposits, 1 ether);
        assertEq(depositTime, block.timestamp);
        assertEq(unblockTime, block.timestamp + 180 days);
        assertEq(debt, 0);
    }

    function test_user_pendingRewards() public {
        vm.prank(user1);
        staking.deposit{value: 1 ether}();

        skip(1 days);
        uint pendingRewards = staking.getPendingRewards(user1);
        uint expectedRewards = 0.01 ether;
        if (pendingRewards >= expectedRewards) {
            assertLt(pendingRewards - expectedRewards, 10);
        } else {
            assertLt(expectedRewards - pendingRewards, 10);
        }
    }

    function test_claim_single_user() public {
        vm.prank(user1);
        staking.deposit{value: 1 ether}();

        skip(1 days);
        uint pendingRewards = staking.getPendingRewards(user1);
        uint expectedRewards = 0.01 ether;
        if (pendingRewards >= expectedRewards) {
            assertLt(pendingRewards - expectedRewards, 10);
        } else {
            assertLt(expectedRewards - pendingRewards, 10);
        }

        uint prevWETHbalance = weth.balanceOf(user1);

        vm.prank(user1);
        staking.claimRewards(true);

        assertEq(weth.balanceOf(user1), prevWETHbalance + expectedRewards);
        // (uint deposits, uint depositTime, uint unblockTime, uint debt) = staking
        //     .userDeposits(user1);
        // assertEq(deposits, 1 ether);
        // assertEq(depositTime, block.timestamp);
        // assertEq(unblockTime, block.timestamp + 180 days);
        // assertEq(debt, 0);
    }

    function test_double_deposit() public {}
}
