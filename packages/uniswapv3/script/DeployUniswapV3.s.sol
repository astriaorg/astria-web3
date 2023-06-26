// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {UniswapV3Factory} from "@uniswap/v3-core/contracts/UniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {UniswapInterfaceMulticall} from "@uniswap/v3-periphery/contracts/lens/UniswapInterfaceMulticall.sol";
import {TickLens} from "@uniswap/v3-periphery/contracts/lens/TickLens.sol";
import {NonfungibleTokenPositionDescriptor} from "@uniswap/v3-periphery/contracts/NonfungibleTokenPositionDescriptor.sol";
import {NonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/NonfungiblePositionManager.sol";
import {V3Migrator} from "@uniswap/v3-periphery/contracts/V3Migrator.sol";
import {QuoterV2} from "@uniswap/v3-periphery/contracts/lens/QuoterV2.sol";
import {UniswapV3Staker} from "@uniswap/v3-staker/contracts/UniswapV3Staker.sol";
import {SwapRouter02} from "@uniswap/swap-router-contracts/contracts/SwapRouter02.sol";
import {ProxyAdmin, TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/ProxyAdmin.sol";

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";

contract DeployUniswapV3 is Script {
    // Config
    address private weth9Address = address(vm.envAddress("WETH9_ADDRESS"));
    bytes32 private nativeCurrencyLabelBytes = keccak256(abi.encodePacked("ETH"));
    // NOTE - we're not actually running v2 uniswap so this is just a dummy address
    address private v2CoreFactoryAddress = address(0x1339);

    uint256 private ONE_MINUTE_SECONDS = 60;
    uint256 private ONE_HOUR_SECONDS = ONE_MINUTE_SECONDS * 60;
    uint256 private ONE_DAY_SECONDS = ONE_HOUR_SECONDS * 24;
    uint256 private ONE_MONTH_SECONDS = ONE_DAY_SECONDS * 30;
    uint256 private ONE_YEAR_SECONDS = ONE_DAY_SECONDS * 365;

    UniswapV3Factory private v3CoreFactoryAddress;
    UniswapInterfaceMulticall private multicall2Address;
    ProxyAdmin private proxyAdminAddress;
    TickLens private tickLensAddress;
    NonfungibleTokenPositionDescriptor private nonfungibleTokenPositionDescriptorAddressV1_3_0;
    TransparentUpgradeableProxy private descriptorProxyAddress;
    NonfungiblePositionManager private nonfungibleTokenPositionManagerAddress;
    V3Migrator private v3MigratorAddress;
    UniswapV3Staker private v3StakerAddress;
    QuoterV2 private quoterV2Address;
    SwapRouter02 private swapRouter02;

    bytes private emptyBytes;

    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        // DEPLOY_V3_CORE_FACTORY
        v3CoreFactoryAddress = new UniswapV3Factory();
        // ADD_1BP_FEE_TIER
        uint24 ONE_BP_FEE = 100;
        int24 ONE_BP_TICK_SPACING = 1;
        v3CoreFactoryAddress.enableFeeAmount(ONE_BP_FEE, ONE_BP_TICK_SPACING);
        // DEPLOY_MULTICALL2
        multicall2Address = new UniswapInterfaceMulticall();
        // DEPLOY_PROXY_ADMIN
        proxyAdminAddress = new ProxyAdmin();
        // DEPLOY_TICK_LENS
        tickLensAddress = new TickLens();
        // DEPLOY_NFT_POSITION_DESCRIPTOR_V1_3_0
        nonfungibleTokenPositionDescriptorAddressV1_3_0 = new NonfungibleTokenPositionDescriptor(
            weth9Address,
            nativeCurrencyLabelBytes
        );
        // DEPLOY_TRANSPARENT_PROXY_DESCRIPTOR
        descriptorProxyAddress = new TransparentUpgradeableProxy(
            address(nonfungibleTokenPositionDescriptorAddressV1_3_0),
            address(proxyAdminAddress),
            emptyBytes
        );
        // DEPLOY_NONFUNGIBLE_POSITION_MANAGER
        nonfungibleTokenPositionManagerAddress = new NonfungiblePositionManager(
            address(v3CoreFactoryAddress),
            weth9Address,
            address(descriptorProxyAddress)
        );
        // DEPLOY_V3_MIGRATOR
        v3MigratorAddress = new V3Migrator(
            address(v3CoreFactoryAddress),
            weth9Address,
            address(nonfungibleTokenPositionManagerAddress)
        );
        // DEPLOY_V3_STAKER
        uint256 MAX_INCENTIVE_START_LEAD_TIME = ONE_MONTH_SECONDS;
        uint256 MAX_INCENTIVE_DURATION = ONE_YEAR_SECONDS * 2;
        v3StakerAddress = new UniswapV3Staker(
            IUniswapV3Factory(address(v3CoreFactoryAddress)),
            nonfungibleTokenPositionManagerAddress,
            MAX_INCENTIVE_START_LEAD_TIME,
            MAX_INCENTIVE_DURATION
        );
        // DEPLOY_QUOTER_V2
        quoterV2Address = new QuoterV2(address(v3CoreFactoryAddress), weth9Address);
        // DEPLOY_V3_SWAP_ROUTER_02
        swapRouter02 = new SwapRouter02(
            v2CoreFactoryAddress,
            address(v3CoreFactoryAddress),
            address(nonfungibleTokenPositionManagerAddress),
            weth9Address
        );
        // TRANSFER_PROXY_ADMIN
        proxyAdminAddress.transferOwnership(msg.sender);
        assert(proxyAdminAddress.owner() == msg.sender);

        console.log(msg.sender);

        vm.stopBroadcast();
    }
}
