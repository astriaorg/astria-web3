// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ProvideLiquidityCustodian} from "../src/ProvideLiquidityCustodian.sol";
import {GenericERC20} from "../src/GenericERC20.sol";

contract UniswapV3LiquidityTest is Test {
    string private constant _MNEMONIC = "test test test test test test test test test test test junk";
    address private steeze_whale;
    IERC20 private steeze;
    IERC20 private burger;

    ProvideLiquidityCustodian public uni;

    function setUp() public {
        (address addr,) = deriveRememberKey(_MNEMONIC, uint32(0));
        steeze_whale = payable(addr);

        vm.startPrank(steeze_whale);
        steeze = new GenericERC20("Steeze", "STEEZE", 30 ether);
        burger = new GenericERC20("Burger", "BURGER", 30 ether);
        address nftPositionManager = address(vm.envAddress("NONFUNGIBLE_POSITION_MANAGER_ADDRESS"));
        uni = new ProvideLiquidityCustodian(nftPositionManager, address(steeze), address(burger));
        steeze.approve(address(uni), 30 ether);
        burger.approve(address(uni), 30 ether);
        vm.stopPrank();
    }

    function testLiquidity() public {
        // Track total liquidity
        uint128 liquidity;

        // Mint new position
        uint steezeAmount = 10 ether;
        uint burgerAmount = 1 ether;

        vm.startPrank(steeze_whale);

        (uint tokenId, uint128 liquidityDelta, uint amount0, uint amount1) = uni
            .mintNewPosition(steezeAmount, burgerAmount);
        liquidity += liquidityDelta;

        console.log("--- Mint new position ---");
        console.log("token id", tokenId);
        console.log("liquidity", liquidity);
        console.log("amount 0", amount0);
        console.log("amount 1", amount1);

        // Collect fees
        (uint fee0, uint fee1) = uni.collectAllFees(tokenId);

        console.log("--- Collect fees ---");
        console.log("fee 0", fee0);
        console.log("fee 1", fee1);

        // Increase liquidity
        uint steezeAmountToAdd = 5 * 1e18;
        uint burgerAmountToAdd = 0.5 * 1e18;

        (liquidityDelta, amount0, amount1) = uni.increaseLiquidityCurrentRange(
            tokenId,
            steezeAmountToAdd,
            burgerAmountToAdd
        );
        vm.stopPrank();

        liquidity += liquidityDelta;

        console.log("--- Increase liquidity ---");
        console.log("liquidity", liquidity);
        console.log("amount 0", amount0);
        console.log("amount 1", amount1);

        // Decrease liquidity
        (amount0, amount1) = uni.decreaseLiquidityCurrentRange(tokenId, liquidity);
        console.log("--- Decrease liquidity ---");
        console.log("amount 0", amount0);
        console.log("amount 1", amount1);
    }
}
