// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol"; //导入测试库
import {XGHToken} from "../src/XGHToken.sol"; //导入测试合约
import {DeployXGHToken} from "../script/DeployXGHToken.s.sol";

contract XGHTokenTest is Test {
    DeployXGHToken public deployer;
    XGHToken public xghToken;

    function setUp() public {
        deployer = new DeployXGHToken();
        xghToken = deployer.run();
    }

    function testInitialSuplay() public view {
        assertEq(xghToken.totalSupply(), deployer.INITIAL_SUPPLY() * 10 ** 18);
    }

    function testTokenName() public view {
        assertEq(xghToken.name(), "XGH Token");
        assertEq(xghToken.symbol(), "XGH");
    }
}
