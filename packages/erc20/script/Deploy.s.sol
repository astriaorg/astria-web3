// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {CustomizableERC20} from "../src/CustomizableERC20.sol";

contract Deploy is Script {

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        CustomizableERC20 token = new CustomizableERC20("Token", "TKN", 1000000000000000000000000);

        vm.stopBroadcast();
    }
}
