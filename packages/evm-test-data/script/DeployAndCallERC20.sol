// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../lib/forge-std/src/Script.sol";
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
        address[] memory addressArray = new address[](addressCount);
        for (uint256 i = 0; i < addressCount; i++) {
            addressArray[i] = address(uint160(12 + i));
        }

        uint256 quantity = 100_000_000_000_000_000_000; // 100 ETH?

        vm.startBroadcast();
        SolmateERC20 token = new SolmateERC20();

        // mint tokens to addresses
        for (uint256 i = 0; i < loopCount; i++) {
            token.mint(addressArray[i % addressCount], quantity);
        }

        // transfer tokens between addresses
        uint256 amount = 1; // 0.000001 ETH?
        for (uint256 i = 0; i < loopCount; i++) {
            require(
                token.allowance(
                    address(this),
                    addressArray[i % addressCount]
                ) >= amount,
                "Transfer amount exceeds allowance"
            );
            token.transferFrom(
                addressArray[i % addressCount],
                addressArray[(i + 1) % addressCount],
                amount
            );
        }

        vm.stopBroadcast();
    }
}
