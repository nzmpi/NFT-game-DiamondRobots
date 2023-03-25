// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewardToken is IERC20 {
    function setMinter(address _newMinter) external;
    function removeMinter(address _oldMinter) external;
    function mint(address _account, uint256 _amount) external;
    function burn(uint256 _amount) external;
}