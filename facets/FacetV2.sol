// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LibDiamond } from "../libs/LibDiamond.sol";
import { IRobotsNFT } from "../interfaces/IRobotsNFT.sol";
import { IUtils } from "../interfaces/IUtils.sol";

/**
 * @title Example of an upgrade of the game
 */
contract FacetV2 {
    
    event robotMintEvent(address indexed minter, uint256 robotId, uint8 attack, uint8 defence);

    function getDoubleMarketTax() external view returns (uint128) {
        return 2*LibDiamond.diamondStorage().marketTax;
    }

    /**
     * @dev Anyone can mint as much as they want now
     */
    function mintRobotWithToken() external returns (uint256 robotId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        IERC20(ds.token).transferFrom(msg.sender, address(this), ds.mintingFeeInToken);

        uint256 dna = _generateRandomDna();
        robotId = _buildRobot(ds.nft, dna);
        ds.hasMinted[msg.sender] = 1;
    }

    function _generateRandomDna() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp)));        
    }

    function _buildRobot(address _nft, uint256 _dna) internal returns (uint256 robotId) {
        uint8 attack = uint8(_dna%10)+1;
        _dna = _dna/10; 
        uint8 defence = uint8(_dna%10)+1;
        robotId = IRobotsNFT(_nft).mint(msg.sender, attack, defence, 0);

        emit robotMintEvent(msg.sender, robotId, attack, defence);
    }
}

