// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {XGHToken} from "../../src/token/XGHToken.sol";
import {DeployXGHToken} from "../../script/token/DeployXGHToken.s.sol";

contract XGHTokenTest is Test {
    XGHToken public xghToken;
    DeployXGHToken deployer;

    // 定义事件
    event Transfer(address indexed from, address indexed to, uint256 value); //转账事件
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    ); // 授权事件
    event Mint(address indexed to, uint256 value); // 铸币事件
    event Burn(address indexed from, uint256 value); // 销毁事件
    event Paused(); // 暂停事件 ，当合约出现问题时，可以暂停合约
    event Unpaused(); // 取消暂停事件， 当合约问题修复时，可以取消暂停合约

    // 测试地址
    address owner;
    address alice = address(0x2);
    address bob = address(0x3);
    address zeroAddress = address(0);

    // 常量
    uint256 public constant INITIAL_SUPPLY = 1000 ether;
    uint256 public constant TRANSFER_AMOUNT = 100 ether;
    uint256 public constant MINT_AMOUNT = 500 ether;
    uint256 public constant BURN_AMOUNT = 200 ether;

    function setUp() public {
        // 部署合约，初始化代币
        //vm.prank(owner);
        deployer = new DeployXGHToken();
        xghToken = deployer.run();
        owner = xghToken.owner();

        // 给 alice 分配初始代币
        vm.prank(owner);
        xghToken.transfer(alice, TRANSFER_AMOUNT);
    }

    // 测试初始状态
    function testXGHInitialState() public view {
        assertEq(xghToken.name(), "XGH Token");
        assertEq(xghToken.symbol(), "XGH");
        assertEq(xghToken.decimals(), 18);
        assertEq(xghToken.totalSupply(), INITIAL_SUPPLY);
        assertEq(xghToken.balanceOf(owner), INITIAL_SUPPLY - TRANSFER_AMOUNT);
        assertEq(xghToken.balanceOf(alice), TRANSFER_AMOUNT);
    }

    // 测试转账功能
    function testXGHTransfer() public {
        vm.prank(alice);
        xghToken.transfer(bob, 50 ether);

        assertEq(xghToken.balanceOf(alice), TRANSFER_AMOUNT - 50 ether);
        assertEq(xghToken.balanceOf(bob), 50 ether);
    }

    // 测试转账事件
    function testXGHTransferEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, 50 ether);

        vm.prank(alice);
        xghToken.transfer(bob, 50 ether);
    }

    // 测试转账到零地址
    function testXGHTransferToZeroAddress() public {
        vm.prank(alice);
        vm.expectRevert("transfer to the zero address");
        xghToken.transfer(zeroAddress, 1 ether);
    }

    // 测试余额不足转账
    function testXGHInsufficientBalanceTransfer() public {
        vm.prank(alice);
        vm.expectRevert("transfer amount exceeds balance");
        xghToken.transfer(bob, TRANSFER_AMOUNT + 1);
    }

    // 测试授权功能
    function testXGHApprove() public {
        vm.prank(alice);
        xghToken.approve(bob, 50 ether);

        assertEq(xghToken.allowance(alice, bob), 50 ether);
    }

    // 测试授权事件
    function testXGHApproveEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Approval(alice, bob, 50 ether);

        vm.prank(alice);
        xghToken.approve(bob, 50 ether);
    }

    // 测试授权到零地址
    function testXGHApproveToZeroAddress() public {
        vm.prank(alice);
        vm.expectRevert("approve to the zero address");
        xghToken.approve(zeroAddress, 50 ether);
    }

    // 测试代理转账功能
    function testXGHTransferFrom() public {
        // 设置授权
        vm.prank(alice);
        xghToken.approve(bob, 50 ether);

        // 执行代理转账
        vm.prank(bob);
        xghToken.transferFrom(alice, bob, 30 ether);

        // 验证结果
        assertEq(xghToken.balanceOf(alice), TRANSFER_AMOUNT - 30 ether);
        assertEq(xghToken.balanceOf(bob), 30 ether);
        assertEq(xghToken.allowance(alice, bob), 50 ether - 30 ether);
    }

    // 测试代理转账事件
    function testXGHTransferFromEvent() public {
        vm.prank(alice);
        xghToken.approve(bob, 50 ether);

        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, 30 ether);

        vm.prank(bob);
        xghToken.transferFrom(alice, bob, 30 ether);
    }

    // 测试代理转账余额不足
    function testXGHTransferFromInsufficientBalance() public {
        vm.prank(alice);
        xghToken.approve(bob, TRANSFER_AMOUNT + 1);

        vm.prank(bob);
        vm.expectRevert("transfer amount exceeds balance");
        xghToken.transferFrom(alice, bob, TRANSFER_AMOUNT + 1);
    }

    // 测试代理转账授权不足
    function testXGHTransferFromInsufficientAllowance() public {
        vm.prank(alice);
        xghToken.approve(bob, 50 ether);

        vm.prank(bob);
        vm.expectRevert("transfer amount exceeds allowance");
        xghToken.transferFrom(alice, bob, 60 ether);
    }

    // 测试增加授权额度
    function testXGHIncreaseAllowance() public {
        vm.prank(alice);
        xghToken.approve(bob, 50 ether);

        vm.prank(alice);
        xghToken.increaseAllowance(bob, 30 ether);

        assertEq(xghToken.allowance(alice, bob), 80 ether);
    }

    // 测试减少授权额度
    function testXGHDecreaseAllowance() public {
        vm.prank(alice);
        xghToken.approve(bob, 50 ether);

        vm.prank(alice);
        xghToken.decreaseAllowance(bob, 30 ether);

        assertEq(xghToken.allowance(alice, bob), 20 ether);
    }

    // 测试减少授权额度低于零
    function testXGHDecreaseAllowanceBelowZero() public {
        vm.prank(alice);
        xghToken.approve(bob, 50 ether);

        vm.prank(alice);
        vm.expectRevert("decreased allowance below zero");
        xghToken.decreaseAllowance(bob, 60 ether);
    }

    // 测试安全授权
    function testXGHSafeApprove() public {
        vm.prank(alice);
        xghToken.safeApprove(bob, 50 ether);

        assertEq(xghToken.allowance(alice, bob), 50 ether);
    }

    // 测试安全授权失败（非零到非零）
    function testXGHSafeApproveFail() public {
        vm.prank(alice);
        xghToken.approve(bob, 50 ether);

        vm.prank(alice);
        vm.expectRevert("approve from non-zero to non-zero allowance");
        xghToken.safeApprove(bob, 60 ether);
    }

    // 测试铸造功能
    function testXGHMint() public {
        uint256 initialSupply = xghToken.totalSupply();

        vm.prank(owner);
        xghToken.mint(alice, MINT_AMOUNT);

        assertEq(xghToken.totalSupply(), initialSupply + MINT_AMOUNT);
        assertEq(xghToken.balanceOf(alice), TRANSFER_AMOUNT + MINT_AMOUNT);
    }

    // 测试铸造事件
    function testXGHMintEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Mint(alice, MINT_AMOUNT);

        vm.prank(owner);
        xghToken.mint(alice, MINT_AMOUNT);
    }

    // 测试非所有者铸造
    function testXGHMintByNonOwner() public {
        vm.prank(alice);
        vm.expectRevert("Only owner can call this function");
        xghToken.mint(alice, MINT_AMOUNT);
    }

    // 测试销毁功能
    function testXGHBurn() public {
        uint256 initialSupply = xghToken.totalSupply();

        vm.prank(alice);
        xghToken.burn(BURN_AMOUNT);

        assertEq(xghToken.totalSupply(), initialSupply - BURN_AMOUNT);
        assertEq(xghToken.balanceOf(alice), TRANSFER_AMOUNT - BURN_AMOUNT);
    }

    // 测试销毁事件
    function testXGHBurnEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Burn(alice, BURN_AMOUNT);

        vm.prank(alice);
        xghToken.burn(BURN_AMOUNT);
    }

    // 测试销毁余额不足
    function testXGHBurnInsufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert("burn amount exceeds balance");
        xghToken.burn(TRANSFER_AMOUNT + 1);
    }

    // 测试暂停功能
    function testXGHPause() public {
        vm.prank(owner);
        xghToken.pause();

        assertEq(xghToken.paused(), true);
    }

    // 测试暂停事件
    function testXGHPauseEvent() public {
        vm.expectEmit(false, false, false, true);
        emit Paused();

        vm.prank(owner);
        xghToken.pause();
    }

    // 测试非所有者暂停
    function testXGHPauseByNonOwner() public {
        vm.prank(alice);
        vm.expectRevert("Only owner can call this function");
        xghToken.pause();
    }

    // 测试恢复功能
    function testXGHUnpause() public {
        vm.prank(owner);
        xghToken.pause();

        vm.prank(owner);
        xghToken.unpause();

        assertEq(xghToken.paused(), false);
    }

    // 测试恢复事件
    function testXGHUnpauseEvent() public {
        vm.prank(owner);
        xghToken.pause();

        vm.expectEmit(false, false, false, true);
        emit Unpaused();

        vm.prank(owner);
        xghToken.unpause();
    }

    // 测试非所有者恢复
    function testXGHUnpauseByNonOwner() public {
        vm.prank(owner);
        xghToken.pause();

        vm.prank(alice);
        vm.expectRevert("Only owner can call this function");
        xghToken.unpause();
    }

    // 测试暂停状态下的转账
    function testXGHTransferWhenPaused() public {
        vm.prank(owner);
        xghToken.pause();

        vm.prank(alice);
        vm.expectRevert("Contract is paused");
        xghToken.transfer(bob, 50 ether);
    }

    // 测试暂停状态下的授权
    function testXGHApproveWhenPaused() public {
        vm.prank(owner);
        xghToken.pause();

        vm.prank(alice);
        vm.expectRevert("Contract is paused");
        xghToken.approve(bob, 50 ether);
    }
}
