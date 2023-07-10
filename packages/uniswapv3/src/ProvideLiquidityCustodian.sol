// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ProvideLiquidityCustodian is IERC721Receiver {
    IERC20 private token0;
    IERC20 private token1;

    int24 private constant MIN_TICK = - 887272;
    int24 private constant MAX_TICK = - MIN_TICK;
    int24 private constant TICK_SPACING = 60;

    INonfungiblePositionManager public nonfungiblePositionManager = INonfungiblePositionManager(0x66C714B1Cb587a5D03Cd2C82249633df0Ff3CC39);

    constructor(IERC20 _token0, IERC20 _token1) public {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function mintNewPosition(
        uint amount0ToAdd,
        uint amount1ToAdd
    ) external returns (uint tokenId, uint128 liquidity, uint amount0, uint amount1) {
        token0.transferFrom(msg.sender, address(this), amount0ToAdd);
        token1.transferFrom(msg.sender, address(this), amount1ToAdd);

        token0.approve(address(nonfungiblePositionManager), amount0ToAdd);
        token1.approve(address(nonfungiblePositionManager), amount1ToAdd);

        INonfungiblePositionManager.MintParams
        memory params = INonfungiblePositionManager.MintParams({
            token0: address(token0),
            token1: address(token1),
            fee: 3000,
            tickLower: (MIN_TICK / TICK_SPACING) * TICK_SPACING,
            tickUpper: (MAX_TICK / TICK_SPACING) * TICK_SPACING,
            amount0Desired: amount0ToAdd,
            amount1Desired: amount1ToAdd,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        console.log("mintNewPosition mint");
        (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(
            params
        );

        if (amount0 < amount0ToAdd) {
            token0.approve(address(nonfungiblePositionManager), 0);
            uint refund0 = amount0ToAdd - amount0;
            token0.transfer(msg.sender, refund0);
        }
        if (amount1 < amount1ToAdd) {
            token1.approve(address(nonfungiblePositionManager), 0);
            uint refund1 = amount1ToAdd - amount1;
            token1.transfer(msg.sender, refund1);
        }
    }

    function collectAllFees(
        uint tokenId
    ) external returns (uint amount0, uint amount1) {
        INonfungiblePositionManager.CollectParams
        memory params = INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (amount0, amount1) = nonfungiblePositionManager.collect(params);
    }

    function increaseLiquidityCurrentRange(
        uint tokenId,
        uint amount0ToAdd,
        uint amount1ToAdd
    ) external returns (uint128 liquidity, uint amount0, uint amount1) {
        token0.transferFrom(msg.sender, address(this), amount0ToAdd);
        token1.transferFrom(msg.sender, address(this), amount1ToAdd);

        token0.approve(address(nonfungiblePositionManager), amount0ToAdd);
        token1.approve(address(nonfungiblePositionManager), amount1ToAdd);

        INonfungiblePositionManager.IncreaseLiquidityParams
        memory params = INonfungiblePositionManager.IncreaseLiquidityParams({
            tokenId: tokenId,
            amount0Desired: amount0ToAdd,
            amount1Desired: amount1ToAdd,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (liquidity, amount0, amount1) = nonfungiblePositionManager.increaseLiquidity(
            params
        );
    }

    function decreaseLiquidityCurrentRange(
        uint tokenId,
        uint128 liquidity
    ) external returns (uint amount0, uint amount1) {
        INonfungiblePositionManager.DecreaseLiquidityParams
        memory params = INonfungiblePositionManager.DecreaseLiquidityParams({
            tokenId: tokenId,
            liquidity: liquidity,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(params);
    }
}
