// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {XXXToken} from "../../src/token/XXXToken.sol";
import {DeployXXXToken} from "../../script/token/DeployXXXToken.s.sol";

contract XXXTokenTest is Test {
    event Transfer(address indexed, address indexed, uint256);

    XXXToken public xxxToken;
    DeployXXXToken public deployer;

    // 测试地址
    address owner;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address zeroAddress = address(0);

    // 常量
    uint256 public constant INITIAL_SUPPLY = 1000 ether;
    uint256 public constant TRANSFER_AMOUNT = 100 ether;

    function setUp() public {
        deployer = new DeployXXXToken();
        xxxToken = deployer.run();
        owner = xxxToken.owner();

        // 初始分配代币给 owner
        vm.prank(owner);
        xxxToken.transfer(bob, TRANSFER_AMOUNT);
    }

    // 基础功能测试
    function testInitialState() public view {
        assertEq(xxxToken.name(), "XXX Token");
        assertEq(xxxToken.symbol(), "XXX");
        assertEq(xxxToken.decimals(), 18);
        assertEq(xxxToken.totalSupply(), INITIAL_SUPPLY);
    }

    function testBobBalance() public view {
        assertEq(xxxToken.balanceOf(bob), TRANSFER_AMOUNT);
    }

    function testBalancesAfterTransfer() public {
        // 转账前余额验证
        assertEq(xxxToken.balanceOf(owner), INITIAL_SUPPLY - TRANSFER_AMOUNT);
        assertEq(xxxToken.balanceOf(bob), TRANSFER_AMOUNT);

        // 执行转账
        vm.prank(bob);
        xxxToken.transfer(alice, 50 ether);

        // 转账后余额验证
        assertEq(xxxToken.balanceOf(bob), TRANSFER_AMOUNT - 50 ether);
        assertEq(xxxToken.balanceOf(alice), 50 ether);
    }

    // 事件测试
    function testTransferEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, 50 ether);

        vm.prank(bob);
        xxxToken.transfer(alice, 50 ether);
    }

    // 边界条件测试
    function testTransferToZeroAddress() public {
        vm.prank(bob);
        vm.expectRevert("ERC20: transfer to the zero address");
        xxxToken.transfer(zeroAddress, 1 ether);
    }

    // 授权功能测试
    function testApproveAndAllowance() public {
        vm.prank(bob);
        xxxToken.approve(alice, 50 ether);

        assertEq(xxxToken.allowance(bob, alice), 50 ether);
    }

    function testTransferFrom() public {
        // 设置授权
        vm.prank(bob);
        xxxToken.approve(alice, 50 ether);

        // 执行转账
        vm.prank(alice);
        xxxToken.transferFrom(bob, alice, 30 ether);

        // 验证结果
        assertEq(xxxToken.balanceOf(bob), TRANSFER_AMOUNT - 30 ether);
        assertEq(xxxToken.balanceOf(alice), 30 ether);
        assertEq(xxxToken.allowance(bob, alice), 50 ether - 30 ether);
    }

    // 权限控制测试（假设代币有铸造功能）
    function testMintByOwner() public {
        uint256 mintAmount = 100 ether;
        uint256 initialTotalSupply = xxxToken.totalSupply();

        vm.prank(owner);
        xxxToken.mint(owner, mintAmount);

        assertEq(xxxToken.totalSupply(), initialTotalSupply + mintAmount);
        assertEq(
            xxxToken.balanceOf(owner),
            (INITIAL_SUPPLY - TRANSFER_AMOUNT) + mintAmount
        );
    }

    function testMintByNonOwner() public {
        vm.prank(bob);
        vm.expectRevert("Ownable: caller is not the owner");
        xxxToken.mint(bob, 100 ether);
    }

    // 销毁功能测试（如果有实现）
    function testBurn() public {
        uint256 burnAmount = 50 ether;
        uint256 initialSupply = xxxToken.totalSupply();

        vm.prank(bob);
        xxxToken.burn(burnAmount);
        console.log(bob);

        assertEq(xxxToken.balanceOf(bob), TRANSFER_AMOUNT - burnAmount);
        assertEq(xxxToken.totalSupply(), initialSupply - burnAmount);
    }

    //安全边界测试
    function testMaxValueTransfer() public {
        uint256 maxValue = type(uint256).max;
        vm.prank(owner);
        xxxToken.transfer(bob, maxValue);
        assertEq(xxxToken.balanceOf(bob), maxValue);
    }

    function testReentrancy() public {
        // 需要合约有重入保护机制
        vm.prank(address(deployer));
        vm.expectRevert("ReentrancyGuard: reentrant call");
        xxxToken.transfer(address(deployer), 1 ether);
    }

    //小数点精度测试
    function testDecimalPrecision() public {
        uint256 amount = 123456789;
        vm.prank(owner);
        xxxToken.transfer(bob, amount);
        assertEq(xxxToken.balanceOf(bob), amount);
    }
}
