// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGrowing {
    function combineRobots(uint256 _robotId1, uint256 _robotId2) external returns (uint256 robotId);
    function multiplyRobots(uint256 _robotId1, uint256 _robotId2) external returns (uint256 robotId);
}