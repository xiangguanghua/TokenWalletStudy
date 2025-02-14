// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// 新增 IERC721Receiver 接口
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @title XGHNfts
 * @dev 纯手工实现的 ERC721 NFT 合约
 */
contract XGHNfts {
    //================================基础数据===================================//
    // 代币名称
    string public name;
    // 代币符号
    string public symbol;
    // 代币元数据
    string private _baseTokenURI;
    //代币计数器
    uint256 private _tokenIdCounter;

    //================================映射===================================//
    //代币所有者映射
    mapping(uint256 => address) private _owners; //代币tokenId所有者
    //地址代币余额映射
    mapping(address => uint256) private _balances;
    //代币授权映射
    mapping(uint256 => address) private _tokenApprovals;
    //操作员授权映射
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    //================================事件===================================//
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    //============================构造函数===================================//
    constructor(
        string memory _name,
        string memory _symbol,
        string memory baseURI
    ) {
        name = _name;
        symbol = _symbol;
        _baseTokenURI = baseURI;
    }

    //===========================ERC721 标准函数==============================//
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Owner query for nonexistent token");
        return owner;
    }

    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "Approval to current owner");
        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "Approve caller is not owner nor approved for all"
        );
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(
            _owners[tokenId] != address(0),
            "Approved query for nonexistent token"
        );
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Transfer caller is not owner nor approved"
        );
        _transfer(from, to, tokenId);
    }

    // ========== 铸造功能 ==========
    function mint(address to) public {
        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;
        _mint(to, tokenId);
    }

    // ========== 元数据管理 ==========
    function setBaseURI(string memory baseURI) public {
        _baseTokenURI = baseURI;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(
            _owners[tokenId] != address(0),
            "URI query for nonexistent token"
        );
        return string(abi.encodePacked(_baseTokenURI, _toString(tokenId)));
    }

    // ========== 辅助函数 ==========
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "Mint to the zero address");
        require(_owners[tokenId] == address(0), "Token already minted");

        _balances[to]++;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "Transfer of token that is not own");
        require(to != address(0), "Transfer to the zero address");

        // 清除授权
        _approve(address(0), tokenId);

        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "Transfer to non ERC721Receiver implementer"
        );
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        require(
            _owners[tokenId] != address(0),
            "Operator query for nonexistent token"
        );
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.code.length == 0) return true;
        try
            IERC721Receiver(to).onERC721Received(
                msg.sender,
                from,
                tokenId,
                _data
            )
        returns (bytes4 retval) {
            // 检查返回值是否为 0x150b7a02（即 onERC721Received 的函数选择器）
            return retval == IERC721Receiver.onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert("Transfer to non ERC721Receiver implementer");
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
