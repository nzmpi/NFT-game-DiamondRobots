// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IRobotsNFT is IERC721 {
    function mint(address _to, uint8 _attack, uint8 _defence, uint32 _readyTime) external returns (uint256);
    function setMinter(address _newMinter) external;
    function removeMinter(address _oldMinter) external;
    function burn(uint256 robotId) external;
    function updateReadyTime(uint256 robotId, uint32 newReadyTime) external;
    function getStats(uint256 robotId) external view returns (uint8 attack, uint8 defence, uint32 readyTime);
}