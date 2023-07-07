// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import "../src/SolmateERC20.sol";

contract DeployAndCallERC20 is Script {
    function run() public {
        // load loopCount from environment
        int256 envLoopCount = vm.envInt(("LOOP_COUNT"));
        require(envLoopCount > 0, "LOOP_COUNT must be greater than 0");
        uint256 loopCount = uint256(envLoopCount);

        // load addressCount from environment
        int256 envAddressCount = vm.envInt(("ADDRESS_COUNT"));
        require(envAddressCount > 0, "ADDRESS_COUNT must be greater than 0");
        uint256 addressCount = uint256(envAddressCount);

        // dynamically create address array
        address payable[] memory addressArray = new address payable[](addressCount);
        for (uint256 i = 0; i < addressCount; i++) {
            string memory mnemonic = "test test test test test test test test test test test junk";
            (address addr,) = deriveRememberKey(mnemonic, uint32(i));
            addressArray[i] = payable(addr);
        }

        uint256 quantity = 100 ether;

        vm.startBroadcast();
        SolmateERC20 token = new SolmateERC20();

        // mint tokens to addresses
        for (uint256 i = 0; i < loopCount; i++) {
            token.mint(addressArray[i % addressCount], quantity);
        }
        vm.stopBroadcast();

        // transfer tokens between addresses
        uint256 amount = 1 ether;
        for (uint256 i = 0; i < loopCount; i++) {
            vm.startBroadcast(addressArray[i % addressCount]);
            token.approve(addressArray[i % addressCount], amount);
            token.transferFrom(
                addressArray[i % addressCount],
                addressArray[(i + 1) % addressCount],
                amount
            );
            vm.stopBroadcast();
        }

    }
}
