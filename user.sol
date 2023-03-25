//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IDiamondCut } from "./interfaces/IDiamondCut.sol";
import { IDiamondLoupe } from "./interfaces/IDiamondLoupe.sol";
import { IOwnershipFacet } from "./interfaces/IOwnershipFacet.sol";
import { IRewardToken } from "./interfaces/IRewardToken.sol";
import { IUtils } from "./interfaces/IUtils.sol";
import { IFactory } from "./interfaces/IFactory.sol";
import { IGrowing } from "./interfaces/IGrowing.sol";
import { IRobotMarket } from "./interfaces/IRobotMarket.sol";
import { IFighting } from "./interfaces/IFighting.sol";

/**
 * @title Example of a user
 */
contract User {

    // The contract of the game (DiamondRobots)
    address public immutable DR;

    constructor(address _DR) {
        DR = _DR;
    }

    /**
     * @dev Returns the address of the owner of DR
     */
    function owner() external view returns (address) {
        return IOwnershipFacet(DR).owner();
    }

    /**
     * @dev Try to transfer the ownership of the game
     * @notice Should revert if EOA is not the owner of the game
     */
    function tryToTransferOwnership(address _newOwner) external {
        IOwnershipFacet(DR).transferOwnership(_newOwner);
    }

    /**
     * @dev Returns the address of the facet,
     * that has '_functionString' function
     */
    function getFacet(string memory _functionString) external view returns (address) {
        bytes4 functionSelector = bytes4(keccak256(bytes(_functionString)));
        return IDiamondLoupe(DR).facetAddress(functionSelector);
    }

    /**
     * @dev try to withdraw as a user
     */    
    function tryToWithdraw() external {
        IUtils(DR).withdraw();
    }

    function getMintingFeeInEth() public view returns (uint128) {
        return IUtils(DR).getMintingFeeInEth();
    }

    function getMintingFeeInToken() public view returns (uint128) {
        return IUtils(DR).getMintingFeeInToken();
    }

    function getCombiningFee() external view returns (uint128) {
        return IUtils(DR).getCombiningFee();
    }

    function getMarketTax() external view returns (uint8) {
        return IUtils(DR).getMarketTax();
    }

    function getRewardToken() public view returns (address) {
        return IUtils(DR).getRewardToken();
    }

    function getNFT() public view returns (address) {
        return IUtils(DR).getNFT();
    }

    function transferNFT(address _to, uint256 _robotId) external {
        IERC721(getNFT()).transferFrom(address(this), _to, _robotId);
    }

    /**
     * @dev Try to set 'MintingFeeInEth' as a user
     */
    function tryToSetMintingFeeInEth(uint128 _newFee) public {
        IUtils(DR).setMintingFeeInEth(_newFee);
    }    

    /**
     * @dev Try to initialize the game again
     */
    function tryToInitAgain(address diamondInit) external {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](0);
        bytes memory callInit = abi.encodeWithSignature("init(address,address)", address(0), address(0));
        IDiamondCut(DR).diamondCut(cuts, diamondInit, callInit);
    }

    function mintRobotWithEth() external payable returns (uint256) {
        return IFactory(DR).mintRobotWithEth{value: msg.value}();
    }

    /**
     * @dev Mint a robot by directly sending eth to the game
     */
    function mintRobotBySendingEth() external payable {
        (bool sent,) = DR.call{value: msg.value}("");
        require(sent, "Couldn't mint!");
    }

    function approveRewardTokenToDR() external {
        IRewardToken(getRewardToken()).approve(DR, type(uint256).max);
    }

    /**
     * @dev Different functions to interact with the game
     */
    function mintRobotWithToken() external returns (uint256) {
        return IFactory(DR).mintRobotWithToken();
    }

    function combineRobots(uint256 _robotId1, uint256 _robotId2) external returns (uint256) {
        IERC721(getNFT()).approve(DR, _robotId1);
        IERC721(getNFT()).approve(DR, _robotId2);
        return IGrowing(DR).combineRobots(_robotId1, _robotId2);
    }

    function multiplyRobots(uint256 _robotId1, uint256 _robotId2) external returns (uint256) {
        return IGrowing(DR).multiplyRobots(_robotId1, _robotId2);
    }

    function putOnMarket(uint256 _robotId, uint256 _price) external {
        IERC721(getNFT()).approve(DR, _robotId);
        IRobotMarket(DR).putOnMarket(_robotId, _price);
    }

    function withdrawFromMarket(uint256 _robotId) external {
        IRobotMarket(DR).withdrawFromMarket(_robotId);
    }

    function buyRobot(uint256 _robotId) external {
        IRobotMarket(DR).buyRobot(_robotId);
    }

    function putOnAuction(uint256 _robotId, uint256 _startingPrice, uint32 _auctionTime) external {
        IERC721(getNFT()).approve(DR, _robotId);
        IRobotMarket(DR).putOnAuction(_robotId, _startingPrice, _auctionTime);
    }

    function withdrawFromAuction(uint256 _robotId) external {
        IRobotMarket(DR).withdrawFromAuction(_robotId);
    }

    function bidOnAuction(uint256 _robotId, uint256 _bid) external {
        IRobotMarket(DR).bidOnAuction(_robotId, _bid);
    }

    function endAuction(uint256 _robotId) external {
        IRobotMarket(DR).endAuction(_robotId);
    }

    function getAuction(uint256 _robotId) external view returns (IRobotMarket.Auction memory) {
        return IRobotMarket(DR).getAuction(_robotId);
    }

    function createArena(uint256 _robotId) external returns (uint128) {
        return IFighting(DR).createArena(_robotId);
    }

    function removeArena(uint128 _arenaId) external {
        IFighting(DR).removeArena(_arenaId);
    }

    function enterArena(uint128 _arenaId, uint256 _attackerRobotId) external {
        IFighting(DR).enterArena(_arenaId, _attackerRobotId);
    }
}