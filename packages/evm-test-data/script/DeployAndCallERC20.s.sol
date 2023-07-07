// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import "../src/SolmateERC20.sol";

contract DeployAndCallERC20 is Script {
    uint256 private constant _QUANTITY_TO_MINT = 100 ether;
    uint256 private constant _QUANTITY_TO_TRANSFER = 1 ether;
    string private constant _MNEMONIC = "test test test test test test test test test test test junk";

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
        address payable[] memory addressArray = new address payable[](
            addressCount
        );
        for (uint256 i = 0; i < addressCount; i++) {
            (address addr, ) = deriveRememberKey(_MNEMONIC, uint32(i));
            addressArray[i] = payable(addr);
        }

        // deploy token
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        SolmateERC20 token = new SolmateERC20();
        for (uint256 i = 0; i < addressCount; i++) {
            // mint tokens to addresses
            token.mint(addressArray[i], _QUANTITY_TO_MINT);
            // send some ether to addresses so they can pay for gas
            (bool success, ) = addressArray[i].call{value: 0.5 ether}("");
            require(success, "Transfer failed.");
        }
        vm.stopBroadcast();

        // transfer tokens between addresses
        for (uint256 i = 0; i < loopCount; i++) {
            vm.startBroadcast(addressArray[i % addressCount]);
            token.transfer(
                addressArray[(i + 1) % addressCount],
                _QUANTITY_TO_TRANSFER
            );
            vm.stopBroadcast();
        }
    }
}
