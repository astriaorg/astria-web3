// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {NonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/NonfungiblePositionManager.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "../src/GenericToken.sol";

contract ProvideLiquidity is Script {
    ERC20 private steezeToken;
    ERC20 private burgerToken;
    NonfungiblePositionManager private nonfungiblePositionManager;
    address payable private nonfungiblePositionManagerAddress;

    uint256 private constant AMOUNT_TO_MINT = 100000;
    uint24 public constant POOL_FEE = 3000;

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        // provide liquidity

        // prepare tokens
        vm.startBroadcast(privateKey);
        // deploy tokens
        steezeToken = new GenericERC20("Steeze", "STEEZE", AMOUNT_TO_MINT);
        burgerToken = new GenericERC20("Burger", "BURGER", AMOUNT_TO_MINT);
        // approve tokens
        nonfungiblePositionManagerAddress = payable(vm.envAddress("NONFUNGIBLE_POSITION_MANAGER_ADDRESS"));
        nonfungiblePositionManager = NonfungiblePositionManager(nonfungiblePositionManagerAddress);

        TransferHelper.safeApprove(address(steezeToken), nonfungiblePositionManagerAddress, AMOUNT_TO_MINT);
        TransferHelper.safeApprove(address(burgerToken), nonfungiblePositionManagerAddress, AMOUNT_TO_MINT);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: address(steezeToken),
            token1: address(burgerToken),
            fee: POOL_FEE,
            tickLower: TickMath.MIN_TICK,
            tickUpper: TickMath.MAX_TICK,
            amount0Desired: AMOUNT_TO_MINT,
            amount1Desired: AMOUNT_TO_MINT,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });
        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = nonfungiblePositionManager.mint(params);

        vm.stopBroadcast();
    }
}
