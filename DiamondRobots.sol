// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./libs/LibDiamond.sol";
import "./interfaces/IDiamondCut.sol";

/**
 * @title Diamond Robots
 * A new version of the Robots game https://github.com/nzmpi/NFT-game-robots
 * This contract uses EIP-2535 (Diamonds) 
 * More info: https://eips.ethereum.org/EIPS/eip-2535
 */
contract DiamondRobots {  

    /**
     * @dev This contract uses tx.origin and not msg.sender
     * to check the owner. Use the deployer wallet
     * only to interact with this contract. 
     * Beware of phishing attacks!
     */
    constructor(address _diamondCutFacet) payable {      
        LibDiamond.setContractOwner(tx.origin);

        // Add the diamondCut external function from the diamondCutFacet
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _diamondCutFacet, 
            action: IDiamondCut.FacetCutAction.Add, 
            functionSelectors: functionSelectors
        });
        LibDiamond.diamondCut(cut, address(0), "");        
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        // get diamond storage
        assembly {
            ds.slot := position
        }
        // get facet from function selector
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        require(facet != address(0), "Diamond: Function does not exist");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    // Sending eth directly to the contract should also mint
    receive() external payable {
       (bool success,) = address(this).delegatecall(abi.encodeWithSignature("mintRobotWithEth()"));
       require(success, "DiamondBase: Coudn't mint");
    }
}
