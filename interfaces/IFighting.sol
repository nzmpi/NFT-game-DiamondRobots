// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFighting {
    function createArena(uint256 _robotId) external returns (uint128 _newArenaId);
    function removeArena(uint128 _arenaId) external;
    function enterArena(uint128 _arenaId, uint256 _attackerRobotId) external;
}