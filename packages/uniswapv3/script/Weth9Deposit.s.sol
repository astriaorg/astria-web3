// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import {IWETH9} from '@uniswap/v3-periphery/contracts/interfaces/external/IWETH9.sol';

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";

contract Weth9Deposit is Script {

    uint256 private tokenAmount = vm.envUint("TOKEN_AMOUNT");

    IWETH9 private weth9;

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        weth9 = IWETH9(vm.envAddress("WETH9_ADDRESS"));
        weth9.deposit{value: tokenAmount}();

        uint256 balance = weth9.balanceOf(msg.sender);
        console.log(msg.sender, " weth balance:", balance);

        vm.stopBroadcast();
    }
}
