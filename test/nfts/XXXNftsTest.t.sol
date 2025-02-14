// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {XXXNfts} from "../../src/nfts/XXXNfts.sol";
import {DeployXXXNfts} from "../../script/nfts/DeployXXXNfts.s.sol";

contract XXXNftsTest is Test {
    DeployXXXNfts public deployer;
    XXXNfts public xxxNfts;
    address public USER = makeAddr("user");
    string public constant PUG =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function setUp() public {
        deployer = new DeployXXXNfts();
        xxxNfts = deployer.run();
    }

    function testNameIsCorrect() public view {
        string memory expecteName = "Dogie";
        string memory actualName = xxxNfts.name();
        assert(
            keccak256(abi.encodePacked(expecteName)) ==
                keccak256(abi.encodePacked(actualName))
        );
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        xxxNfts.mintNfts(PUG);
        assert(xxxNfts.balanceOf(USER) == 1);
        assert(
            keccak256(abi.encodePacked(PUG)) ==
                keccak256(abi.encodePacked(xxxNfts.tokenURI(0)))
        );
    }
}
