// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint private seed;

    mapping(address => uint) public lastWavedAt;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {   
        address waver;
        string message; 
        uint256 timestamp; 
    }

    struct Winners {   
        address waver;
        string message; 
        uint256 timestamp; 
        uint256 amount;
    }

    Wave[] waves;

    Winners[] winners;

    constructor() payable {
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string calldata _message) public {
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 30 sec"
        );

        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;

        console.log("%s has waved!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %d", seed);

        if (seed <= 50) {
            uint256 prizeAmount = 0.0001 ether;
            winners.push(Winners(msg.sender, _message, block.timestamp, prizeAmount));
            console.log("%s won!", msg.sender);

            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);

    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }

    function getAllWinners() public view returns(Winners[] memory) {
        return winners;
    }

}