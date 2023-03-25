//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import { DiamondRobots } from "./DiamondRobots.sol";
import { IDiamondCut } from "./interfaces/IDiamondCut.sol";
import { DiamondCutFacet } from "./facets/DiamondCutFacet.sol";
import { DiamondInit } from "./initializer/DiamondInit.sol";

import { DiamondLoupeFacet } from "./facets/DiamondLoupeFacet.sol";
import { OwnershipFacet } from "./facets/OwnershipFacet.sol";
import { Utils } from "./facets/Utils.sol";
import { Factory } from "./facets/Factory.sol";
import { Growing } from "./facets/Growing.sol";
import { RobotMarket } from "./facets/RobotMarket.sol";
import { Fighting } from "./facets/Fighting.sol";

/**
 * @title A deployer of the game
 * Deploys all facets and adds all related selectors,
 * then initializes the game and renounces ownership 
 * of this contract
 */
contract Deployer is Ownable {
    address immutable diamondCutFacet;
    address immutable diamondLoupeFacet;
    address public immutable diamondRobots;
    address public immutable diamondInit;
    
    constructor() {
        diamondCutFacet = address(new DiamondCutFacet());
        diamondRobots = address(new DiamondRobots(diamondCutFacet));
        diamondInit = address(new DiamondInit());
        diamondLoupeFacet = address(new DiamondLoupeFacet());
    }

    function deployFacets(address _token, address _nft) external onlyOwner {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](7);

        bytes4[] memory selsOfDiamondLoupeFacet = new bytes4[](5);
        selsOfDiamondLoupeFacet[0] = DiamondLoupeFacet.facets.selector; 
        selsOfDiamondLoupeFacet[1] = DiamondLoupeFacet.facetFunctionSelectors.selector; 
        selsOfDiamondLoupeFacet[2] = DiamondLoupeFacet.facetAddresses.selector;
        selsOfDiamondLoupeFacet[3] = DiamondLoupeFacet.facetAddress.selector; 
        selsOfDiamondLoupeFacet[4] = DiamondLoupeFacet.supportsInterface.selector; 
        cuts[0] = IDiamondCut.FacetCut(diamondLoupeFacet, IDiamondCut.FacetCutAction.Add, selsOfDiamondLoupeFacet);
        
        bytes4[] memory selsOfOwnershipFacet = new bytes4[](2);
        address ownershipFacet = address(new OwnershipFacet());
        selsOfOwnershipFacet[0] = OwnershipFacet.transferOwnership.selector; 
        selsOfOwnershipFacet[1] = OwnershipFacet.owner.selector; 
        cuts[1] = IDiamondCut.FacetCut(ownershipFacet, IDiamondCut.FacetCutAction.Add, selsOfOwnershipFacet);

        address utils = address(new Utils());
        cuts[2] = UtilsFacet.getCut(utils);

        address factory = address(new Factory());
        cuts[3] = FactoryFacet.getCut(factory);

        address growing = address(new Growing());
        cuts[4] = GrowingFacet.getCut(growing);

        address robotMarket = address(new RobotMarket());
        cuts[5] = RobotMarketFacet.getCut(robotMarket);

        address fighting = address(new Fighting());
        cuts[6] = FightingFacet.getCut(fighting);

        bytes memory callInit = abi.encodeWithSignature("init(address,address)", _token, _nft);
        IDiamondCut(diamondRobots).diamondCut(cuts, diamondInit, callInit);

        renounceOwnership();
    }
}

library UtilsFacet {
    function getCut(address utils) external pure returns (IDiamondCut.FacetCut memory) {
        
        bytes4[] memory selectors = new bytes4[](29);
        selectors[0] = Utils.withdraw.selector;
        selectors[1] = Utils.setMintingFeeInEth.selector; 
        selectors[2] = Utils.getMintingFeeInEth.selector; 
        selectors[3] = Utils.setMintingFeeInToken.selector;
        selectors[4] = Utils.getMintingFeeInToken.selector; 
        selectors[5] = Utils.setCombiningFee.selector; 
        selectors[6] = Utils.getCombiningFee.selector; 
        selectors[7] = Utils.setMultiplyingFee.selector; 
        selectors[8] = Utils.getMultiplyingFee.selector; 
        selectors[9] = Utils.setFightingFee.selector; 
        selectors[10] = Utils.getFightingFee.selector; 
        selectors[11] = Utils.setMarketTax.selector; 
        selectors[12] = Utils.getMarketTax.selector; 
        selectors[13] = Utils.setAuctionTax.selector; 
        selectors[14] = Utils.getAuctionTax.selector; 
        selectors[15] = Utils.setFightingTax.selector; 
        selectors[16] = Utils.getFightingTax.selector;
        selectors[17] = Utils.setCombiningTax.selector; 
        selectors[18] = Utils.getCombiningTax.selector; 
        selectors[19] = Utils.setMultiplyingTax.selector; 
        selectors[20] = Utils.getMultiplyingTax.selector;
        selectors[21] = Utils.setMultiplyingCooldown.selector;
        selectors[22] = Utils.getMultiplyingCooldown.selector; 
        selectors[23] = Utils.setReward.selector; 
        selectors[24] = Utils.getReward.selector; 
        selectors[25] = Utils.setRewardToken.selector;
        selectors[26] = Utils.getRewardToken.selector;
        selectors[27] = Utils.setNFT.selector; 
        selectors[28] = Utils.getNFT.selector;
        return IDiamondCut.FacetCut(utils, IDiamondCut.FacetCutAction.Add, selectors);
    }
}

library FactoryFacet {
    function getCut(address factory) external pure returns (IDiamondCut.FacetCut memory) {
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = Factory.mintRobotWithEth.selector;
        selectors[1] = Factory.mintRobotWithToken.selector;
        return IDiamondCut.FacetCut(factory, IDiamondCut.FacetCutAction.Add, selectors);
    }
}

library GrowingFacet {
    function getCut(address growing) external pure returns (IDiamondCut.FacetCut memory) {
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = Growing.combineRobots.selector;
        selectors[1] = Growing.multiplyRobots.selector;
        return IDiamondCut.FacetCut(growing, IDiamondCut.FacetCutAction.Add, selectors);
    }
}

library RobotMarketFacet {
    function getCut(address robotMarket) external pure returns (IDiamondCut.FacetCut memory) {
        bytes4[] memory selectors = new bytes4[](8);
        selectors[0] = RobotMarket.putOnMarket.selector;
        selectors[1] = RobotMarket.withdrawFromMarket.selector;
        selectors[2] = RobotMarket.buyRobot.selector;
        selectors[3] = RobotMarket.putOnAuction.selector;
        selectors[4] = RobotMarket.withdrawFromAuction.selector;
        selectors[5] = RobotMarket.bidOnAuction.selector;
        selectors[6] = RobotMarket.endAuction.selector;
        selectors[7] = RobotMarket.getAuction.selector;
        return IDiamondCut.FacetCut(robotMarket, IDiamondCut.FacetCutAction.Add, selectors);
    }
}

library FightingFacet {
    function getCut(address fighting) external pure returns (IDiamondCut.FacetCut memory) {
        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = Fighting.createArena.selector;
        selectors[1] = Fighting.removeArena.selector;
        selectors[2] = Fighting.enterArena.selector;
        return IDiamondCut.FacetCut(fighting, IDiamondCut.FacetCutAction.Add, selectors);
    }
}