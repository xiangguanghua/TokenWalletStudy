// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {XGHToken} from "../src/XGHToken.sol";
import {console} from "forge-std/Test.sol";

contract DeployXGHToken is Script {
    uint256 public constant INITIAL_SUPPLY = 100000000; //一亿枚

    function run() public returns (XGHToken) {
        vm.startBroadcast();
        XGHToken xghToken = new XGHToken(INITIAL_SUPPLY, "XGH Token", "XGH");
        vm.stopBroadcast();

        // 打印部署的合约地址
        console.log("XGHToken deployed to:", address(xghToken));
        return xghToken;
    }
}
