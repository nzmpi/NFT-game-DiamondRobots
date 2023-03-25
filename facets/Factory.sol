//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../libs/LibDiamond.sol";
import { IRobotsNFT } from "../interfaces/IRobotsNFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title A contract to mint robots
 * Each address can only mint once either with eth or with the reward tokens
 * @dev To mint a unique robot !!pseudorandomness!! is used
 */
contract Factory {

    event robotMintEvent(address indexed minter, uint256 robotId, uint8 attack, uint8 defence);

    error AlreadyMinted();
    error FailedEthTransfer();

    function mintRobotWithEth() public payable returns (uint256 robotId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if (ds.hasMinted[msg.sender] != 0) revert AlreadyMinted();
        require(msg.value >= ds.mintingFeeInEth, "Not enough eth to mint!");
        uint256 dna = _generateRandomDna();
        robotId = _buildRobot(ds.nft, dna);
        ds.hasMinted[msg.sender] = 1;

        
        /**
         * @dev Doesn't work for Diamonds
         */
        // return excess eth
        /*uint256 mintingFeeInEth = ds.mintingFeeInEth;
        if (msg.value - mintingFeeInEth > 0) {
            (bool sent,) = msg.sender.call{value: msg.value - mintingFeeInEth}("");
            if(!sent) revert FailedEthTransfer();
        }*/
    }

    function mintRobotWithToken() external returns (uint256 robotId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if (ds.hasMinted[msg.sender] != 0) revert AlreadyMinted();
        IERC20(ds.token).transferFrom(msg.sender, address(this), ds.mintingFeeInToken);

        uint256 dna = _generateRandomDna();
        robotId = _buildRobot(ds.nft, dna);
    }

    // Pseudorandom is used to generate dna
    function _generateRandomDna() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp)));        
    }

    // Last digit of dna is 'attack' and next digit is 'defence'
    function _buildRobot(address _nft, uint256 _dna) internal returns (uint256 robotId) {
        uint8 attack = uint8(_dna%10)+1;
        _dna = _dna/10; 
        uint8 defence = uint8(_dna%10)+1;
        robotId = IRobotsNFT(_nft).mint(msg.sender, attack, defence, 0);

        emit robotMintEvent(msg.sender, robotId, attack, defence);
    }
}
