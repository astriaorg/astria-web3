// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import "../src/SolmateERC20.sol";

contract DeployAndCallERC20 is Script {
    uint256 constant private QUANTITY_TO_MINT = 100 ether;
    uint256 constant private QUANTITY_TO_TRANSFER = 1 ether;

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

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        // deploy token
        SolmateERC20 token = new SolmateERC20();
        for (uint256 i = 0; i < addressCount; i++) {
            // mint tokens to addresses
            token.mint(addressArray[i], QUANTITY_TO_MINT);
            // send some ether to addresses so they can pay for gas
            addressArray[i].send(0.5 ether);
        }
        vm.stopBroadcast();

        // transfer tokens between addresses
        for (uint256 i = 0; i < loopCount; i++) {
            vm.startBroadcast(addressArray[i % addressCount]);
            token.transfer(addressArray[(i + 1) % addressCount], QUANTITY_TO_TRANSFER);
            vm.stopBroadcast();
        }

    }
}
