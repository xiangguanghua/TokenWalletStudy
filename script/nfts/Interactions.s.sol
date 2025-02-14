// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {XXXNfts} from "../../src/nfts/XXXNfts.sol";
import {MoodNfts} from "../../src/nfts/MoodNfts.sol";

contract MintXXXNfts is Script {
    // string public constant PUG_URI = "ipfs://QmVgw23gPsfuVXoNcmvxPZECGSUqib1ceB4YS8KG5qd5zN/?filename=xgh.json";

    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function run() external {
        address mostRecentlyDeployedXXXNfts = DevOpsTools
            .get_most_recent_deployment("XXXNfts", block.chainid);
        mintNftOnContract(mostRecentlyDeployedXXXNfts);
    }

    function mintNftOnContract(address xxxNftsAddress) public {
        vm.startBroadcast();
        XXXNfts(xxxNftsAddress).mintNfts(PUG_URI);
        vm.stopBroadcast();
    }
}

contract MintMoodNfts is Script {
    function run() external {
        address mostRecentlyDeployedMoodNft = DevOpsTools
            .get_most_recent_deployment("MoodNfts", block.chainid);
        mintNftOnContract(mostRecentlyDeployedMoodNft);
    }

    function mintNftOnContract(address moodNftAddress) public {
        vm.startBroadcast();
        MoodNfts(moodNftAddress).mintNft();
        vm.stopBroadcast();
    }
}

contract FlipMoodNft is Script {
    uint256 public constant TOKEN_ID_TO_FLIP = 1;

    function run() external {
        address mostRecentlyDeployedMoodNft = DevOpsTools
            .get_most_recent_deployment("MoodNfts", block.chainid);
        flipMoodNft(mostRecentlyDeployedMoodNft);
    }

    function flipMoodNft(address moodNftAddress) public {
        vm.startBroadcast();
        MoodNfts(moodNftAddress).flipMood(TOKEN_ID_TO_FLIP);
        vm.stopBroadcast();
    }
}
