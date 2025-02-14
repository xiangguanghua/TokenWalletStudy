// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {XXXNfts} from "../../src/nfts/XXXNfts.sol";

contract DeployXXXNfts is Script {
    function run() external returns (XXXNfts) {
        vm.startBroadcast();
        XXXNfts xxxNfts = new XXXNfts();
        vm.stopBroadcast();
        return xxxNfts;
    }
}
