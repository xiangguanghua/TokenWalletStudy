// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {XXXToken} from "../src/XXXToken.sol";

contract DeployXXXToken is Script {
    uint256 public constant INITI_SUPPLY = 1000 ether;

    function run() external returns (XXXToken) {
        vm.startBroadcast();
        XXXToken xxxToken = new XXXToken(INITI_SUPPLY);
        vm.stopBroadcast();
        return xxxToken;
    }
}
