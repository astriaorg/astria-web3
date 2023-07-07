// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "../src/GenericToken.sol";

contract SwapTokens is Script {
    uint256 private constant AMOUNT_TO_MINT = 100000;
    uint24 public constant POOL_FEE = 3000;

    function run() external {
        ISwapRouter router = ISwapRouter(vm.envAddress("UNISWAP_V3_ROUTER_ADDRESS"));

        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        ERC20 steezeToken = new GenericERC20("Steeze", "STEEZE", AMOUNT_TO_MINT);
        ERC20 burgerToken = new GenericERC20("Burger", "BURGER", 2 * AMOUNT_TO_MINT);

        // swap tokens
        steezeToken.approve(address(router), AMOUNT_TO_MINT);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(steezeToken),
            tokenOut: address(burgerToken),
            fee: POOL_FEE,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: AMOUNT_TO_MINT,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        uint256 amountOut = router.exactInputSingle(params);

        console.log("amountOut: %s", amountOut);

        vm.stopBroadcast();
    }

}
