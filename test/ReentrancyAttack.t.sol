// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/// @author CatellaTech
/// @title testing a contract vulnerable to reentrancy
import "forge-std/Test.sol";
import { GoodContract } from "../src/GoodContract.sol";
import { BadContract } from "../src/BadContract.sol";

contract ReentrancyAttackTest is Test {
    GoodContract public goodContract;
    BadContract public badContract;
    
    address public  INNOCENT = vm.addr(0x01);
    address public ATTACKER = vm.addr(0x02);
    
    function setUp() public {
        goodContract = new GoodContract();
        badContract = new BadContract(address(goodContract));
        
        vm.deal(INNOCENT, 10 ether);
        vm.deal(ATTACKER, 2 ether);
    }

    /// @notice testInnocentTransfer: Simulating the transfer of 10 ether from an innocent user to the vulnerable contract.
    function testInnocentTransfer() public {
        vm.startPrank(INNOCENT);
        goodContract.addBalance{value: 10 ether}();
        vm.stopPrank();
        uint goodContractBalance = address(goodContract).balance;
        emit log_named_uint("good Contract Balance: ", goodContractBalance);
        assertEq(goodContractBalance, 10 ether);
    }

    
    /// @notice testBadContract: An attacker creates the `badContract` which contains the logic to exploit the `goodContract`, calls the attack function and drains all funds from the `goodContract`.
    function testBadContract() public {
        testInnocentTransfer();
        vm.startPrank(ATTACKER);
        badContract.attack{value: 2 ether}();
        uint goodContractBalanceAfterAttack = address(goodContract).balance;
        emit log_named_uint("good Contract Balance After Attack: ", goodContractBalanceAfterAttack);
        assertEq(goodContractBalanceAfterAttack, 0 ether);
    }
}
