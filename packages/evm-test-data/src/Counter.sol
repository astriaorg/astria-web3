// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract Counter is Test {
    uint256 public number;

    function setup() public {
        number = 10;
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

    function test_increment() public {
        increment();
        assertEq(number, 11);
    }
}
