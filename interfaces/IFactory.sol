// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFactory {
    function mintRobotWithEth() external payable returns (uint256 robotId);
    function mintRobotWithToken() external returns (uint256 robotId);
}