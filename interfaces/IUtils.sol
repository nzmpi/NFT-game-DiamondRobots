// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUtils {
    function withdraw() external;
    function setMintingFeeInEth(uint128 _newMintingFeeInEth) external;
    function getMintingFeeInEth() external view returns (uint128);
    function setMintingFeeInToken(uint128 _newMintingFeeInToken) external;
    function getMintingFeeInToken() external view returns (uint128);
    function setCombiningFee(uint128 _newCombiningFee) external;
    function getCombiningFee() external view returns (uint128);
    function setMultiplyingFee(uint128 _newMultiplyingFee) external;
    function getMultiplyingFee() external view returns (uint128);
    function setFightingFee(uint128 _newFightingFee) external;
    function getFightingFee() external view returns (uint128);
    function setMarketTax(uint8 _newMarketTax) external;
    function getMarketTax() external view returns (uint8);
    function setAuctionTax(uint8 _newAuctionTax) external;
    function getAuctionTax() external view returns (uint8);
    function setFightingTax(uint8 _newFightingTax) external;
    function getFightingTax() external view returns (uint8);
    function setCombiningTax(uint8 _newCombiningTax) external;
    function getCombiningTax() external view returns (uint8);
    function setMultiplyingTax(uint8 _newMultiplyingTax) external;
    function getMultiplyingTax() external view returns (uint8);
    function setMultiplyingCooldown(uint32 _newCooldown) external;
    function getMultiplyingCooldown() external view returns (uint32);
    function setReward(uint128 _newReward) external;
    function getReward() external view returns (uint128);
    function setRewardToken(address _newRewardToken) external;
    function getRewardToken() external view returns (address);
    function setNFT(address _newNFT) external;
    function getNFT() external view returns (address);
}