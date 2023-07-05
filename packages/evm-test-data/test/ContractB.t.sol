// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ContractB.sol";

contract Counter is Test {
    ContractB public contractB;
    function setUp() public {
        contractB = new ContractB();
    }

    function test_SetNumber(uint256 x) public {
        contractB.setNumber(x);
        assertEq(contractB.testNumber(), x);
    }

    function test_revertSubtract() public {
        contractB.setNumber(42);
        vm.expectRevert(stdError.arithmeticError);
        contractB.subtract(43);
    }
}
