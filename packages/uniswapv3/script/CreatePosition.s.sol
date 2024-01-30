// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import {UniswapV3Factory} from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import {UniswapV3Pool} from "@uniswap/v3-core/contracts/UniswapV3Pool.sol";
import {INonfungiblePositionManager} from '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import {TransferHelper} from '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import {TickMath} from '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import {IWETH9} from '@uniswap/v3-periphery/contracts/interfaces/external/IWETH9.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";

contract CreatePosition is Script {

    address private token0 = vm.envAddress("TOKEN_A_ADDRESS");
    address private token1 = vm.envAddress("TOKEN_B_ADDRESS");
    uint24 private fee = uint24(vm.envUint("FEE"));

    uint256 private token0Amount = vm.envUint("TOKEN_A_AMOUNT");
    uint256 private token1Amount = vm.envUint("TOKEN_B_AMOUNT");

    UniswapV3Factory private v3CoreFactory;
    UniswapV3Pool private v3Pool;
    INonfungiblePositionManager private nonfungiblePositionManager;

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        if (token0 > token1) {
            (token0, token1) = (token1, token0);
            (token0Amount, token1Amount) = (token1Amount, token0Amount);
        }

        // get tickSpacing
        v3CoreFactory = UniswapV3Factory(vm.envAddress("UNIV3_FACTORY"));
        address poolAddr = v3CoreFactory.getPool(token0, token1, fee);
        require(poolAddr != address(0x00), "UNKNOWN_POOL");
        v3Pool = UniswapV3Pool(poolAddr);
        int24 tickSpacing = v3Pool.tickSpacing();

        nonfungiblePositionManager = INonfungiblePositionManager(vm.envAddress("UNIV3_POSITION_MANAGER"));

        // add allowance
        uint256 maxApproval = 2**256 - 1;
        TransferHelper.safeApprove(token0, address(nonfungiblePositionManager), maxApproval);
        TransferHelper.safeApprove(token1, address(nonfungiblePositionManager), maxApproval);

        // mint position
        INonfungiblePositionManager.MintParams memory params =
            INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: fee,
                tickLower: (TickMath.MIN_TICK / tickSpacing) * tickSpacing,
                tickUpper: (TickMath.MAX_TICK / tickSpacing) * tickSpacing,
                amount0Desired: token0Amount,
                amount1Desired: token1Amount,
                amount0Min: 1,
                amount1Min: 1,
                recipient: address(msg.sender),
                deadline: block.timestamp + 600
            });

        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = nonfungiblePositionManager.mint(params);
        console.log(tokenId, liquidity, amount0, amount1);

        // Remove allowance
        TransferHelper.safeApprove(token0, address(nonfungiblePositionManager), 0);
        TransferHelper.safeApprove(token1, address(nonfungiblePositionManager), 0);

        vm.stopBroadcast();
    }
}