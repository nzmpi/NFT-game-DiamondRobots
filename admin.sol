//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IDiamondCut } from "./interfaces/IDiamondCut.sol";
import { IDiamondLoupe } from "./interfaces/IDiamondLoupe.sol";
import { IOwnershipFacet } from "./interfaces/IOwnershipFacet.sol";
import { IUtils } from "./interfaces/IUtils.sol";
import { FacetV2 } from "./facets/FacetV2.sol";

/**
 * @title Example of an admin contract
 * @notice EOA that deployed the game should be used
 */
contract Admin {

    // The contract of the game (DiamondRobots)
    address public immutable DR;

    constructor(address _DR) {
        DR = _DR;
    }

    /**
     * @dev Different functions to interact with the game 
     * as the owner
     */
    function owner() external view returns (address) {
        return IOwnershipFacet(DR).owner();
    }

    function transferOwnership(address _newOwner) external {
        IOwnershipFacet(DR).transferOwnership(_newOwner);
    }

    function getFacet(string memory _functionString) external view returns (address) {
        bytes4 functionSelector = bytes4(keccak256(bytes(_functionString)));
        return IDiamondLoupe(DR).facetAddress(functionSelector);
    }

    function withdraw() external {
        IUtils(DR).withdraw();
    }

    function getMintingFeeInEth() public view returns (uint128) {
        return IUtils(DR).getMintingFeeInEth();
    }

    function setMintingFeeInEth(uint128 _newMintingFeeInEth) public {
        IUtils(DR).setMintingFeeInEth(_newMintingFeeInEth);
    }

    function getMarketTax() external view returns (uint8) {
        return IUtils(DR).getMarketTax();
    }

    function setMarketTax(uint8 _newMarketTax) external {
        IUtils(DR).setMarketTax(_newMarketTax);
    }

    function getRewardToken() public view returns (address) {
        return IUtils(DR).getRewardToken();
    }

    function setRewardToken(address _newRewardToken) external {
        IUtils(DR).setRewardToken(_newRewardToken);
    } 

    function getNFT() public view returns (address) {
        return IUtils(DR).getNFT();
    }

    function setNFT(address _newNFT) external {
        IUtils(DR).setNFT(_newNFT);
    }

    /**
     * @dev Try to initialize the game again
     */
    function tryToInitAgain(address diamondInit) external {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](0);
        bytes memory callInit = abi.encodeWithSignature("init(address,address)", address(0), address(0));
        IDiamondCut(DR).diamondCut(cuts, diamondInit, callInit);
    }

    /**
     * @dev Add the new function 'getDoubleMarketTax' from FacetV2
     */
    function addNewFunction() external {
        address facetV2 = address(new FacetV2());
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory selsOfFacetV2 = new bytes4[](1);
        selsOfFacetV2[0] = FacetV2.getDoubleMarketTax.selector; 
        cuts[0] = IDiamondCut.FacetCut(facetV2, IDiamondCut.FacetCutAction.Add, selsOfFacetV2);
        IDiamondCut(DR).diamondCut(cuts, address(0), "");
    }    

    /**
     * @dev Remove that function
     */
    function removeFunction() external {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory selsOfFacetV2 = new bytes4[](1);
        selsOfFacetV2[0] = FacetV2.getDoubleMarketTax.selector; 
        cuts[0] = IDiamondCut.FacetCut(address(0), IDiamondCut.FacetCutAction.Remove, selsOfFacetV2);
        IDiamondCut(DR).diamondCut(cuts, address(0), "");
    }

    /**
     * @dev Call getDoubleMarketTax()
     */
    function getDoubleMarketTax() external view returns (uint128) {
        return FacetV2(DR).getDoubleMarketTax();
    }

    /**
     * @dev Replace mintRobotWithToken() from the game
     * with a new function from FacetV2
     */
    function replaceFunction() external {
        address facetV2 = address(new FacetV2());
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory selsOfFacetV2 = new bytes4[](1);
        selsOfFacetV2[0] = FacetV2.mintRobotWithToken.selector; 
        cuts[0] = IDiamondCut.FacetCut(facetV2, IDiamondCut.FacetCutAction.Replace, selsOfFacetV2);
        IDiamondCut(DR).diamondCut(cuts, address(0), "");
    }
}