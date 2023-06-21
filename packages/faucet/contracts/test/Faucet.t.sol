// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "./utilities/Utilities.sol";
import "../src/MockERC20.sol";
import "../src/Faucet.sol";


contract FaucetTest is Test {
    Utilities internal utils;
    address payable[] internal users;
    address internal owner;
    address internal dev;
    Faucet public faucet;
    MockERC20 public token;

    function setUp() public virtual {
        utils = new Utilities();
        users = utils.createUsers(2);
        owner = users[0];
        vm.label(owner, "Owner");
        dev = users[1];
        vm.label(dev, "Developer");

        token = new MockERC20();
        token.mint(address(owner), 100 ether);

        vm.prank(owner);
        faucet = new Faucet(address(token));
    }

    function testTopUpFaucet() public {
        vm.startPrank(owner);
        token.approve(address(faucet), 50 ether);
        faucet.topUpTokens(50 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(address(faucet)), 50 ether);
    }

    function testRequestTokens() public {
        // Initial state
        assertEq(token.balanceOf(dev), 0);

        // Try to request tokens without sufficient funds in the faucet
        vm.prank(dev);
        vm.expectRevert("Not enough tokens in the faucet.");
        faucet.requestTokens();

        // Top up faucet and try again
        vm.startPrank(owner);
        token.approve(address(faucet), 50 ether);
        faucet.topUpTokens(50 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(address(faucet)), 50 ether);

        // Request tokens as dev
        vm.prank(dev);
        faucet.requestTokens();

        assertEq(token.balanceOf(dev), faucet.tokenAmount());
        assertEq(token.balanceOf(address(faucet)), 40 ether);
    }
}
