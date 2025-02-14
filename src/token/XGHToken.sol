// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title XGH 代币
 * @author xiangguanghua@163.com
 * @notice ERC20完整实现方案，实现标准ERC20方法。支持代币锻造和销毁，支持授权额度新增和减少，支持安全授权。
 */
contract XGHToken {
    string public name; // 代币名称：XGH Token
    string public symbol; // 代币符号 XGH
    uint8 public immutable decimals = 18; // 代币小数位
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply; // 代币总供应量

    address public owner; // 合约拥有者
    bool public paused; // 暂停功能标志

    mapping(address => uint256) private _balanceOf; // 保存地址对应的Token数量
    mapping(address => mapping(address => uint256)) private _allowance; // 保存授权地址的Token数量

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

    // 初始化代币
    constructor(
        uint256 initialSupply, // 初始化代币供应量
        string memory tokenName, // 代币名称
        string memory tokenSymbol //代币符号
    ) {
        owner = msg.sender; // 部署合约的地址为合约拥有者
        totalSupply = initialSupply; // 计算代币总供应量
        _balanceOf[msg.sender] = totalSupply; // 初始化合约创建者的Token数量
        name = tokenName; // 初始化代币名称
        symbol = tokenSymbol; // 初始化代币符号

        paused = false; // 初始化合约未暂停
    }

    // 合约拥有者判断
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    //判断是否赞同
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    // 暂停
    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

    // 基本的转账方法：调用者转账给_to地址_value数量的Token
    function transfer(
        address _to,
        uint256 _value
    ) public whenNotPaused returns (bool success) {
        require(_to != address(0), "transfer to the zero address"); // 接收地址不能为0地址
        require(
            _balanceOf[msg.sender] >= _value,
            "transfer amount exceeds balance"
        ); // 调用者Token数量必须大于等于_value

        _balanceOf[msg.sender] -= _value; // 减少调用者Token数量
        _balanceOf[_to] += _value; // 增加接收者Token数量

        //记录转账事件
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // 授权_spender地址能从调用者地址转移_value数量的Token
    function approve(
        address _spender,
        uint256 _value
    ) public whenNotPaused returns (bool success) {
        require(_spender != address(0), "approve to the zero address"); // 授权地址不能为0地址

        _allowance[msg.sender][_spender] = _value; // 记录授权地址的Token数量
        emit Approval(msg.sender, _spender, _value); // 记录授权事件
        return true;
    }

    // // 代理转账方法，允许从_from地址转账_value数量的Token给_to地址
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public whenNotPaused returns (bool success) {
        require(_to != address(0), "transfer from the zero address"); // 接收地址不能为0地址
        require(_from != address(0), "transfer from the zero address"); // 转账地址不能为0地址
        require(_balanceOf[_from] >= _value, "transfer amount exceeds balance"); // 转账地址Token数量必须大于等于_value
        require(
            _allowance[_from][msg.sender] >= _value,
            "transfer amount exceeds allowance"
        );
        require(_balanceOf[_to] + _value >= _balanceOf[_to]); // 检查地址Token数量是否溢出

        uint256 previousBalances = _balanceOf[_from] + _balanceOf[_to]; // 记录转账前双方Token数量

        _balanceOf[_from] -= _value; //转账方减少数量
        _balanceOf[_to] += _value; // 接收方增加数量
        _allowance[_from][msg.sender] -= _value; // 减少授权方的Token数量

        emit Transfer(_from, _to, _value); //记录转账数据
        assert(_balanceOf[_from] + _balanceOf[_to] == previousBalances); // 检查转账后双方Token数量是否正确
        return true;
    }

    // 增加授权额度的方法
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public whenNotPaused returns (bool) {
        require(
            spender != address(0),
            "increase allowance to the zero address"
        );

        _allowance[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    // 减少授权额度的方法
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public whenNotPaused returns (bool) {
        require(
            spender != address(0),
            "ERC20: decrease allowance to the zero address"
        );

        uint256 currentAllowance = _allowance[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "decreased allowance below zero"
        );

        unchecked {
            _allowance[msg.sender][spender] =
                currentAllowance -
                subtractedValue;
        }

        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    // 安全的 approve 方法，避免重复授权漏洞
    function safeApprove(
        address spender,
        uint256 amount
    ) public whenNotPaused returns (bool) {
        require(
            amount == 0 || _allowance[msg.sender][spender] == 0,
            "approve from non-zero to non-zero allowance"
        );
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 锻造（增发）代币
    function mint(
        address to,
        uint256 amount
    ) public onlyOwner whenNotPaused returns (bool) {
        require(to != address(0), "mint to the zero address");

        totalSupply += amount;
        _balanceOf[to] += amount;

        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
        return true;
    }

    // 销毁代币
    function burn(uint256 amount) public whenNotPaused returns (bool) {
        require(
            _balanceOf[msg.sender] >= amount,
            "burn amount exceeds balance"
        );

        _balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        emit Burn(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    // 暂停合约
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        emit Paused();
        return true;
    }

    // 恢复暂停状态
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        emit Unpaused();
        return true;
    }

    /**************getter方法************** */
    // 获取调用者地址的Token数量
    function balanceOf(address _owner) public view returns (uint256 balance) {
        require(_owner != address(0), "_owner to the zero address"); // 地址不能为0地址
        return _balanceOf[_owner];
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        require(_owner != address(0), "_owner to the zero address"); // 地址不能为0地址
        require(_spender != address(0), "_spender to the zero address"); // 地址不能为0地址
        return _allowance[_owner][_spender];
    }
}
