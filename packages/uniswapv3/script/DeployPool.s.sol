// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import {UniswapV3Factory} from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import {UniswapV3Pool} from "@uniswap/v3-core/contracts/UniswapV3Pool.sol";
import {FullMath} from "@uniswap/v3-core/contracts/libraries/FullMath.sol";

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {Math} from "./Math.sol";

contract DeployPool is Script {
    // Config
    address private tokenA = vm.envAddress("TOKEN_A_ADDRESS");
    address private tokenB = vm.envAddress("TOKEN_B_ADDRESS");
    uint24 private fee = uint24(vm.envUint("FEE"));
    uint256 private price = vm.envUint("PRICE");

    UniswapV3Factory private v3CoreFactory;
    UniswapV3Pool private v3Pool;

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        v3CoreFactory = UniswapV3Factory(vm.envAddress("UNI_V3_FACTORY"));

        // DEPLOY POOL
        address poolAddr = v3CoreFactory.getPool(tokenA, tokenB, fee);
        if (poolAddr == address(0x00)) {
            console.log("Pool does not exist; creating...");

            v3CoreFactory.createPool(tokenA, tokenB, fee);

            poolAddr = v3CoreFactory.getPool(tokenA, tokenB, fee);

            console.log("Created pool:", poolAddr);
        } else {
            console.log("Found pool:", poolAddr);
        }

        // INITIALIZE POOL
        v3Pool = UniswapV3Pool(poolAddr);

        (uint160 sqrtPriceX96,,,,,,) = v3Pool.slot0();

        if (sqrtPriceX96 == 0) {
            console.log("Initializing pools with price", price);

            sqrtPriceX96 = uint160(Math.sqrt(price) << 96);

            v3Pool.initialize(sqrtPriceX96);
        } else {
            uint256 calcedPrice = FullMath.mulDiv(uint256(sqrtPriceX96) * uint256(sqrtPriceX96), 1, 1 << 192);
            console.log("Pool already initialized. Price =", calcedPrice);
        }

        console.log(msg.sender);

        vm.stopBroadcast();
    }
}

// https://ethereum.stackexchange.com/questions/98685/computing-the-uniswap-v3-pair-price-from-q64-96-number
// https://www.degencode.com/p/uniswapv3-pool-contract
// TODO initialize pool with value
