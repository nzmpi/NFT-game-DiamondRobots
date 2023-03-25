//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../libs/LibDiamond.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title A Utils contract
 * @dev This contract stores all basic functions,
 * that can get and set taxes, fees, addresses
 */
contract Utils {

    event newCombiningTaxEvent(uint8 oldCombiningTax, uint8 newCombiningTax);
    event newCombiningFeeEvent(uint128 oldCombiningFee, uint128 newCombiningFee);
    event newMultiplyingTaxEvent(uint8 oldMultiplyingTax, uint8 newMultiplyingTax);
    event newMultiplyingFeeEvent(uint128 oldMultiplyingFee, uint128 newMultiplyingFee);
    event newMultiplyingCooldownEvent(uint32 oldMultiplyingCooldown, uint32 newMultiplyingCooldown);
    event withdrawEvent(uint256 amountEth, uint256 amountToken);
    event newMintingFeeInEthEvent(uint128 oldMintingFeeInEth, uint128 newMintingFeeInEth);
    event newMintingFeeInTokenEvent(uint128 oldMintingFeeInToken, uint128 newMintingFeeInToken);
    event newFightingTaxEvent(uint8 oldFightingTax, uint8 newFightingTax);
    event newFightingFeeEvent(uint128 oldFightingFee, uint128 newFightingFee);
    event newRewardEvent(uint128 oldReward, uint128 newReward);
    event newMarketTaxEvent(uint8 oldMarketTax, uint8 newMarketTax);
    event newAuctionTaxEvent(uint8 oldAuctionTax, uint8 newAuctionTax);
    event newRewardTokenEvent(address oldRewardToken, address newRewardToken);
    event newNFTEvent(address oldNFT, address newNFT);

    error FailedEthTransfer();
    error TaxIsTooHigh();

    function withdraw() external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address owner = ds.contractOwner;
        address token = ds.token;

        uint256 amountEth = address(this).balance;
        uint256 amountToken = IERC20(token).balanceOf(address(this));

        if (amountEth > 0) {
            (bool sent, ) = owner.call{value: amountEth}("");
            if(!sent) revert FailedEthTransfer();
        }
        if (amountToken > 0) {
            IERC20(token).transfer(owner, amountToken);
        }
        emit withdrawEvent(amountEth, amountToken);
    }

    // Fucntions to set and get fees and taxes
    function setMintingFeeInEth(uint128 _newMintingFeeInEth) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newMintingFeeInEthEvent(ds.mintingFeeInEth, _newMintingFeeInEth);
        ds.mintingFeeInEth = _newMintingFeeInEth;
    }

    function getMintingFeeInEth() external view returns (uint128) {
        return LibDiamond.diamondStorage().mintingFeeInEth;
    }

    function setMintingFeeInToken(uint128 _newMintingFeeInToken) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newMintingFeeInTokenEvent(ds.mintingFeeInToken, _newMintingFeeInToken);
        ds.mintingFeeInToken = _newMintingFeeInToken;
    }

    function getMintingFeeInToken() external view returns (uint128) {
        return LibDiamond.diamondStorage().mintingFeeInToken;
    }

    function setCombiningFee(uint128 _newCombiningFee) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newCombiningFeeEvent(ds.combiningFee, _newCombiningFee);
        ds.combiningFee = _newCombiningFee;
    }

    function getCombiningFee() external view returns (uint128) {
        return LibDiamond.diamondStorage().combiningFee;
    }

    function setMultiplyingFee(uint128 _newMultiplyingFee) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newMultiplyingFeeEvent(ds.multiplyingFee, _newMultiplyingFee);
        ds.multiplyingFee = _newMultiplyingFee;
    }

    function getMultiplyingFee() external view returns (uint128) {
        return LibDiamond.diamondStorage().multiplyingFee;
    }

    function setFightingFee(uint128 _newFightingFee) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newFightingFeeEvent(ds.fightingFee, _newFightingFee);
        ds.fightingFee = _newFightingFee;
    }

    function getFightingFee() external view returns (uint128) {
        return LibDiamond.diamondStorage().fightingFee;
    }

    function setMarketTax(uint8 _newMarketTax) external {
        LibDiamond.enforceIsContractOwner();
        if (_newMarketTax > 100) revert TaxIsTooHigh();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newMarketTaxEvent(ds.marketTax, _newMarketTax);
        ds.marketTax = _newMarketTax;
    }

    function getMarketTax() external view returns (uint8) {
        return LibDiamond.diamondStorage().marketTax;
    }

    function setAuctionTax(uint8 _newAuctionTax) external {
        LibDiamond.enforceIsContractOwner();
        if (_newAuctionTax > 100) revert TaxIsTooHigh();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newAuctionTaxEvent(ds.auctionTax, _newAuctionTax);
        ds.auctionTax = _newAuctionTax;
    }

    function getAuctionTax() external view returns (uint8) {
        return LibDiamond.diamondStorage().auctionTax;
    }

    function setFightingTax(uint8 _newFightingTax) external {
        LibDiamond.enforceIsContractOwner();
        if (_newFightingTax > 100) revert TaxIsTooHigh();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newFightingTaxEvent(ds.fightingTax, _newFightingTax);
        ds.fightingTax = _newFightingTax;
    }

    function getFightingTax() external view returns (uint8) {
        return LibDiamond.diamondStorage().fightingTax;
    }

    function setCombiningTax(uint8 _newCombiningTax) external {
        LibDiamond.enforceIsContractOwner();
        if (_newCombiningTax > 100) revert TaxIsTooHigh();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newCombiningTaxEvent(ds.combiningTax, _newCombiningTax);
        ds.combiningTax = _newCombiningTax;
    }

    function getCombiningTax() external view returns (uint8) {
        return LibDiamond.diamondStorage().combiningTax;
    }

    function setMultiplyingTax(uint8 _newMultiplyingTax) external {
        LibDiamond.enforceIsContractOwner();
        if (_newMultiplyingTax > 100) revert TaxIsTooHigh();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newMultiplyingTaxEvent(ds.multiplyingTax, _newMultiplyingTax);
        ds.multiplyingTax = _newMultiplyingTax;
    }

    function getMultiplyingTax() external view returns (uint8) {
        return LibDiamond.diamondStorage().multiplyingTax;
    }

    // Set new multiplying cooldown
    function setMultiplyingCooldown(uint32 _newCooldown) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newMultiplyingCooldownEvent(ds.multiplyingCooldown, _newCooldown);
        ds.multiplyingCooldown = _newCooldown;
    }

    function getMultiplyingCooldown() external view returns (uint32) {
        return LibDiamond.diamondStorage().multiplyingCooldown;
    }

    function setReward(uint128 _newReward) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newRewardEvent(ds.reward, _newReward);
        ds.reward = _newReward;
    }

    function getReward() external view returns (uint128) {
        return LibDiamond.diamondStorage().reward;
    }

    // Functions to set and det addresses of 
    // the reward token and NFT
    function setRewardToken(address _newRewardToken) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newRewardTokenEvent(ds.token, _newRewardToken);
        ds.token = _newRewardToken;
    }

    function getRewardToken() external view returns (address) {
        return LibDiamond.diamondStorage().token;
    }

    function setNFT(address _newNFT) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        emit newRewardTokenEvent(ds.nft, _newNFT);
        ds.nft = _newNFT;
    }

    function getNFT() external view returns (address) {
        return LibDiamond.diamondStorage().nft;
    }
}