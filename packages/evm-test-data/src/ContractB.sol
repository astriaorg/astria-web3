// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract ContractB {
    uint256 public testNumber;

    function setNumber(uint256 newNumber) public {
        testNumber = newNumber;
    }

    function subtract(uint256 x) public {
        testNumber -= x;
    }
}
