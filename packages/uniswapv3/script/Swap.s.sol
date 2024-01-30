// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import {ISwapRouter} from '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import {TransferHelper} from '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import {SwapRouter} from '@uniswap/v3-periphery/contracts/SwapRouter.sol';

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";

contract Swap is Script {

    address private tokenIn = vm.envAddress("TOKEN_IN_ADDRESS");
    address private tokenOut = vm.envAddress("TOKEN_OUT_ADDRESS");
    uint24 private fee = uint24(vm.envUint("FEE"));
    uint256 private amountIn = vm.envUint("TOKEN_IN_AMOUNT");

    ISwapRouter private swapRouter;

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        swapRouter = new SwapRouter(vm.envAddress("UNIV3_FACTORY"), vm.envAddress("WETH9"));

        // add allowance
        uint256 maxApproval = 2**256 - 1;
        TransferHelper.safeApprove(tokenIn, address(swapRouter), maxApproval);

        // swap it
        ISwapRouter.ExactInputSingleParams memory params =
          ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: fee,
            recipient: address(msg.sender),
            deadline: block.timestamp + 600,
            amountIn: amountIn,
            amountOutMinimum: 1,
            sqrtPriceLimitX96: 0
          });

        swapRouter.exactInputSingle(params);

        // Remove allowance
        TransferHelper.safeApprove(tokenIn, address(swapRouter), 0);

        vm.stopBroadcast();
    }
}
