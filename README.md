# 代码介绍

项目代码包括标准 Token 和非同质化 Token。  
手写版本：XGHToken.sol 和 XGHNfts.sol  
继承 Openzeppelin 版本：XXXToken.sol 和 XXXNfts.sol

代码包含了部署脚本和大量的测试用例

# XGHToken ERC20 代币功能说明

ERC20 完整实现方案，实现标准 ERC20 方法。支持代币锻造和销毁，支持授权额度新增和减少，支持安全授权。

### 一、基本 ERC-20 功能：

1、转账：transfer 用于将代币从一个地址转移到另一个地址。  
2、授权和代理转账：approve 用于授权，transferFrom 用于代理转账。  
3、增减授权额度：increaseAllowance 和 decreaseAllowance 分别用于增减授权额度。  
4、安全的 approve：safeApprove 方法避免了重复授权漏洞。

### 二、锻造与销毁：

1、mint：由合约拥有者调用，用于铸造新的代币并分配给指定的地址。每次铸币都会增加 totalSupply。  
2、burn：允许代币持有者销毁自己的代币。销毁时 totalSupply 会减少，代币数量也减少。

### 三、暂停与恢复功能：

1、pause：合约拥有者可以暂停合约，这将禁止所有的代币转账（包括 transfer、transferFrom 和授权相关的操作）。  
2、unpause：恢复暂停状态，恢复代币的正常转账功能。

### 四、合约拥有者：

1、该合约有一个 onlyOwner 修饰符，确保只有合约的拥有者（即部署合约的地址）才能执行一些关键操作，如锻造（增发）代币、销毁代币、暂停和恢复合约。

### 五、使用场景：

1、代币增发：合约拥有者可以根据需求进行代币的增发。  
2、销毁代币：用户可以销毁自己的代币，以减少供应量。  
3、暂停功能：当合约出现安全问题时，合约拥有者可以暂停合约，防止代币被转移。

# XXXToken ERC20 代币功能说明

XXXToken 继承了 openzeppelin 的 ERC20 和 Ownable 合约，编写了完整的单元测试用例，测试方案说明如下：  
1、基础状态测试：验证代币名称、符号、小数位等元数据、检查初始供应量是否正确  
2、转账功能测试：正常转账操作验证、转账事件触发验证  
3、零地址转账保护：余额不足转账失败测试  
4、授权机制测试：授权额度设置验证、授权转账操作验证、授权额度更新验证  
5、权限控制测试：铸造权限验证（owner/non-owner）、销毁权限验证（如果有实现）  
6、边界条件测试：最大金额转账测试、零金额转账测试、整数溢出保护测试（OpenZeppelin 已内置）  
7、事件验证：转账事件参数验证、授权事件验证

部署测试环境地址：https://sepolia.etherscan.io/address/0x3925a01152249aD550d2A30dA7fCA58c4b0B6D55
NFT 代币地址：https://sepolia.etherscan.io/token/0x3925a01152249aD550d2A30dA7fCA58c4b0B6D55
