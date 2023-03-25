//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../libs/LibDiamond.sol";
import "../interfaces/IRobotsNFT.sol";
import "../interfaces/IRewardToken.sol";

/**
 * @title A contract to create new robots
 */
contract Growing {

    /**
     * @dev Keeps parameters of robots,
     * otherwise gives 'Stack too deep' error
     */
    struct ParametersOfRobots {
        uint8 attack1;
        uint8 defence1;
        uint32 readyTime1;
        uint8 attack2;
        uint8 defence2;
        uint32 readyTime2;        
    }

    event combineRobotsEvent(address indexed minter, uint256 robotId1, uint256 robotId2, uint256 newRobotId, uint8 attack, uint8 defence);
    event multiplyRobotsEvent(address indexed minter, uint256 robotId1, uint256 robotId2, uint256 newRobotId, uint8 attack, uint8 defence, uint32 ReadyTime);

    error NotOwnerOf(uint256 robotId);
    error NotReadyToMultiply(uint256 robotId);

    /** 
     * Takes 2 robots and combines them into new one
     * @dev 2 robots and 'combiningFee' tokens must be approved
     */
    function combineRobots(uint256 _robotId1, uint256 _robotId2) external returns (uint256 robotId) {
        ParametersOfRobots memory param = ParametersOfRobots(0,0,0,0,0,0);
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address nft = ds.nft;
        address token = ds.token;
        uint256 combiningFee = ds.combiningFee;

        if (IRobotsNFT(nft).ownerOf(_robotId1) != msg.sender) revert NotOwnerOf(_robotId1);
        if (IRobotsNFT(nft).ownerOf(_robotId2) != msg.sender) revert NotOwnerOf(_robotId2);

        IRobotsNFT(nft).transferFrom(msg.sender, address(this), _robotId1);
        IRobotsNFT(nft).transferFrom(msg.sender, address(this), _robotId2);
        IRewardToken(token).transferFrom(msg.sender, address(this), combiningFee);

        (param.attack1, param.defence1,) = IRobotsNFT(nft).getStats(_robotId1);
        (param.attack2, param.defence2,) = IRobotsNFT(nft).getStats(_robotId2);
        
        // _max10 returns 10 or less
        uint8 newAttack = _max10(param.attack1 + param.attack2);
        uint8 newDefence = _max10(param.defence1 + param.defence2);
        robotId = IRobotsNFT(nft).mint(msg.sender, newAttack, newDefence, 0);
        
        // Burns 2 initial robots and (tokens-Tax)
        IRobotsNFT(nft).burn(_robotId1);
        IRobotsNFT(nft).burn(_robotId2);
        IRewardToken(token).burn(combiningFee*(1000-10*ds.combiningTax)/1000);

        emit combineRobotsEvent(msg.sender, _robotId1, _robotId2, robotId, newAttack, newDefence);
    }

    /**
     * Takes 2 robots and creates a new one
     * @dev 2 robots and 'multiplyingFee' tokens must be approved
     */
    function multiplyRobots(uint256 _robotId1, uint256 _robotId2) external returns (uint256 robotId) {
        ParametersOfRobots memory param = ParametersOfRobots(0,0,0,0,0,0);
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address nft = ds.nft;
        address token = ds.token;
        uint256 multiplyingFee = ds.multiplyingFee;

        if (IRobotsNFT(nft).ownerOf(_robotId1) != msg.sender) revert NotOwnerOf(_robotId1);
        if (IRobotsNFT(nft).ownerOf(_robotId2) != msg.sender) revert NotOwnerOf(_robotId2);

        (param.attack1, param.defence1, param.readyTime1) = IRobotsNFT(nft).getStats(_robotId1);
        (param.attack2, param.defence2, param.readyTime2) = IRobotsNFT(nft).getStats(_robotId2);

        if (param.readyTime1 >= block.timestamp) revert NotReadyToMultiply(_robotId1);
        if (param.readyTime2 >= block.timestamp) revert NotReadyToMultiply(_robotId2);

        IRewardToken(token).transferFrom(msg.sender, address(this), multiplyingFee);
        IRewardToken(token).burn(multiplyingFee*(1000-10*ds.multiplyingTax)/1000);

        uint8 newAttack = (param.attack1 + param.attack2)/2;
        uint8 newDefence = (param.defence1 + param.defence2)/2;
        uint32 newReadyTime = uint32(block.timestamp) + ds.multiplyingCooldown;
        robotId = IRobotsNFT(nft).mint(msg.sender, newAttack, newDefence, newReadyTime);

        IRobotsNFT(nft).updateReadyTime(_robotId1, newReadyTime);
        IRobotsNFT(nft).updateReadyTime(_robotId2, newReadyTime);

        emit multiplyRobotsEvent(msg.sender, _robotId1, _robotId2, robotId, newAttack, newDefence, newReadyTime);
    }

    // Returns 10 or lower
    function _max10(uint8 x) internal pure returns (uint8) {
        return x > 10 ? 10 : x;
    }
}