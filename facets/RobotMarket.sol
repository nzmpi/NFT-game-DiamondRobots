//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../libs/LibDiamond.sol";
import "../interfaces/IRobotsNFT.sol";
import "../interfaces/IRewardToken.sol";

/**
 * @title A market contract
 * @notice Robots can only be bought with the reward token
 */
contract RobotMarket {

    event putOnMarketEvent(address indexed seller, uint256 robotId, uint256 price);
    event withdrawFromMarketEvent(address indexed seller, uint256 robotId);
    event withdrawFromAuctionEvent(address indexed seller, uint256 robotId);
    event buyRobotEvent(address indexed buyer, uint256 robotId, uint256 price);
    event putOnAuctionEvent(address indexed seller, uint256 robotId, uint256 startingPrice, uint32 auctionTime);
    event bidOnAuctionEvent(address indexed bidder, uint256 robotId, uint256 bid);
    event endAuctionEvent(address indexed ender, address indexed highestBidder, uint256 robotId);

    error NotOwnerOf(uint256 robotId);
    error CannotSellForZero();
    error RobotIsNotOnMarket(uint256 robotId);
    error RobotIsNotOnAuction(uint256 robotId);
    error BidIsSmall(uint256 highestBid);
    
    function putOnMarket(uint256 _robotId, uint256 _price) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address nft = ds.nft;

        if (IRobotsNFT(nft).ownerOf(_robotId) != msg.sender) revert NotOwnerOf(_robotId);
        if (_price == 0) revert CannotSellForZero();

        IRobotsNFT(nft).transferFrom(msg.sender, address(this), _robotId);
        ds.market[_robotId] = _price;
        ds.oldOwner[_robotId] = msg.sender;
        emit putOnMarketEvent(msg.sender, _robotId, _price);
    }

    function withdrawFromMarket(uint256 _robotId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if (ds.market[_robotId] == 0) revert RobotIsNotOnMarket(_robotId);
        
        if (ds.oldOwner[_robotId] != msg.sender) revert NotOwnerOf(_robotId);
        
        delete ds.oldOwner[_robotId];
        delete ds.market[_robotId];

        IRobotsNFT(ds.nft).transferFrom(address(this), msg.sender, _robotId);
        emit withdrawFromMarketEvent(msg.sender, _robotId);
    }

    function buyRobot(uint256 _robotId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 price = ds.market[_robotId];
        if (price == 0) revert RobotIsNotOnMarket(_robotId);

        address token = ds.token;
        IRewardToken(token).transferFrom(msg.sender, address(this), price);
        IRewardToken(token).transfer(ds.oldOwner[_robotId], price*(1000-10*ds.marketTax)/1000);

        delete ds.oldOwner[_robotId];
        delete ds.market[_robotId];
   
        IRobotsNFT(ds.nft).transferFrom(address(this), msg.sender, _robotId); 
        emit buyRobotEvent(msg.sender, _robotId, price);
    }

    function putOnAuction(uint256 _robotId, uint256 _startingPrice, uint32 _auctionTime) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address nft = ds.nft;

        if (IRobotsNFT(nft).ownerOf(_robotId) != msg.sender) revert NotOwnerOf(_robotId);
        if (_startingPrice == 0) revert CannotSellForZero();
        require(_auctionTime > 0, "Auction time should be > 0 !");

        IRobotsNFT(nft).transferFrom(msg.sender, address(this), _robotId); 
        ds.oldOwner[_robotId] = msg.sender;
        ds.auctions[_robotId] = LibDiamond.Auction(uint32(block.timestamp)+_auctionTime, address(0), _startingPrice);
        emit putOnAuctionEvent(msg.sender, _robotId, _startingPrice, _auctionTime);
    }

    function withdrawFromAuction(uint256 _robotId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.Auction memory tempAuction = ds.auctions[_robotId];
        if (tempAuction.highestBid == 0) revert RobotIsNotOnAuction(_robotId);

        if (ds.oldOwner[_robotId] != msg.sender) revert NotOwnerOf(_robotId);
        require(tempAuction.highestBidder == address(0), "Someone placed a bid!");

        delete ds.oldOwner[_robotId];
        delete ds.auctions[_robotId];

        IRobotsNFT(ds.nft).transferFrom(address(this), msg.sender, _robotId); 
        emit withdrawFromAuctionEvent(msg.sender, _robotId);
    }

    function bidOnAuction(uint256 _robotId, uint256 _bid) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.Auction memory tempAuction = ds.auctions[_robotId];
        if (tempAuction.highestBid == 0) revert RobotIsNotOnAuction(_robotId);
        require(tempAuction.endTime > block.timestamp, "The auction has ended!");

        // The first bid can be equal to 'startingPrice'
        if (tempAuction.highestBidder == address(0)) {
            if (_bid < tempAuction.highestBid) revert BidIsSmall(tempAuction.highestBid);
        } else 
            if (_bid <= tempAuction.highestBid) revert BidIsSmall(tempAuction.highestBid);
        
        address token = ds.token;
        IRewardToken(token).transferFrom(msg.sender, address(this), _bid);

        // If not the first bid then send previous 'highestBid' to previous 'highestBidder'
        if (tempAuction.highestBidder != address(0)) {
            IRewardToken(token).transfer(tempAuction.highestBidder, tempAuction.highestBid);
        }

        ds.auctions[_robotId].highestBid = _bid;
        ds.auctions[_robotId].highestBidder = msg.sender;
        emit bidOnAuctionEvent(msg.sender, _robotId, _bid);
    }

    // Anyone can end an auction
    function endAuction(uint256 _robotId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.Auction memory tempAuction = ds.auctions[_robotId];
        if (tempAuction.highestBid == 0) revert RobotIsNotOnAuction(_robotId);
        require(tempAuction.endTime < block.timestamp, "The auction hasn't ended yet!");

        address owner = ds.oldOwner[_robotId];
        delete ds.oldOwner[_robotId];
        delete ds.auctions[_robotId];

        // Checks for any bids
        if (tempAuction.highestBidder != address(0)) {
            IRewardToken(ds.token).transfer(owner, tempAuction.highestBid*(1000-10*ds.auctionTax)/1000);
            IRobotsNFT(ds.nft).transferFrom(address(this), tempAuction.highestBidder, _robotId);
        } else {
            IRobotsNFT(ds.nft).transferFrom(address(this), owner, _robotId); 
        }

        emit endAuctionEvent(msg.sender, tempAuction.highestBidder, _robotId);
    }

    function getAuction(uint256 _robotId) external view returns (LibDiamond.Auction memory) {
        return LibDiamond.diamondStorage().auctions[_robotId];
    }
}