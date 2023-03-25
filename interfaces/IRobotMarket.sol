// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRobotMarket {
    function putOnMarket(uint256 _robotId, uint256 _price) external;
    function withdrawFromMarket(uint256 _robotId) external;
    function buyRobot(uint256 _robotId) external;
    function putOnAuction(uint256 _robotId, uint256 _startingPrice, uint32 _auctionTime) external;
    function withdrawFromAuction(uint256 _robotId) external;
    function bidOnAuction(uint256 _robotId, uint256 _bid) external;
    function endAuction(uint256 _robotId) external;
    function getAuction(uint256 _robotId) external view returns (Auction memory);

    struct Auction {
        uint32 endTime;
        address highestBidder;
        uint256 highestBid;
    }
}