//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../libs/LibDiamond.sol";
import "../interfaces/IRobotsNFT.sol";
import "../interfaces/IRewardToken.sol";

/**
 * @title A contract for fighting with robots
 */
contract Fighting {

    event createArenaEvent(address indexed creator, uint256 robotId, uint128 arenaId);
    event removeArenaEvent(address indexed creator, uint128 arenaId);
    event fightingEvent(address indexed winner, uint256 winnerRobotId, address indexed loser, uint256 loserRobotId);

    error NotOwnerOf(uint256 robotId);
    error ArenaIsNotActive(uint128 arenaId);
    error SomeoneIsFighting(uint128 arenaId);

    /**
     * Create an arena by paying 'fightingFee'
     * @notice Number of arenas is not limited
     */
    function createArena(uint256 _robotId) external returns (uint128 newArenaId) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if (IRobotsNFT(ds.nft).ownerOf(_robotId) != msg.sender) revert NotOwnerOf(_robotId);

        IRewardToken(ds.token).transferFrom(msg.sender, address(this), ds.fightingFee);

        newArenaId = ds.newArenaId;
        ds.arenas[newArenaId] = LibDiamond.Arena(1, 0, uint128(_robotId)); 
        emit createArenaEvent(msg.sender, _robotId, newArenaId);
        ++ds.newArenaId;
    }

    function removeArena(uint128 _arenaId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.Arena memory tempArena = ds.arenas[_arenaId];
        if (tempArena.isArenaActive == 0) revert ArenaIsNotActive(_arenaId);

        uint256 robotId = tempArena.creatorsRobotId;
        require(IRobotsNFT(ds.nft).ownerOf(robotId) == msg.sender, "Not the creator!");
        if (tempArena.isFighting == 1) revert SomeoneIsFighting(_arenaId);

        delete ds.arenas[_arenaId];
        IRewardToken(ds.token).transfer(msg.sender, ds.fightingFee);
        emit removeArenaEvent(msg.sender, _arenaId);
    }

    // Anyone can pick any free arena and fight by paying 'fightingFee'
    function enterArena(uint128 _arenaId, uint256 _attackerRobotId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address nft = ds.nft;

        address attacker = IRobotsNFT(nft).ownerOf(_attackerRobotId);
        if (attacker != msg.sender) revert NotOwnerOf(_attackerRobotId);

        LibDiamond.Arena memory tempArena = ds.arenas[_arenaId];
        if (tempArena.isArenaActive == 0) revert ArenaIsNotActive(_arenaId);
        if (tempArena.isFighting == 1) revert SomeoneIsFighting(_arenaId);

        address token = ds.token;
        uint128 fightingFee = ds.fightingFee;
        IRewardToken(token).transferFrom(attacker, address(this), fightingFee);
        ds.arenas[_arenaId].isFighting = 1;

        uint256 defenderRobotId = tempArena.creatorsRobotId;
        address defender = IRobotsNFT(nft).ownerOf(defenderRobotId);
        bool attackerIsWinner = _fighting(nft, defenderRobotId, _attackerRobotId, _arenaId);
        
        // Reward the winner with (2*fightingFee-tax) + mint 'reward'
        if (attackerIsWinner) {
            IRewardToken(token).transfer(attacker, 2*fightingFee*(1000-10*ds.fightingTax)/1000);
            IRewardToken(token).mint(attacker, ds.reward);

            emit fightingEvent(attacker, _attackerRobotId, defender, defenderRobotId);
        } else {
            IRewardToken(token).transfer(defender, 2*fightingFee*(1000-10*ds.fightingTax)/1000);
            IRewardToken(token).mint(defender, ds.reward);

            emit fightingEvent(defender, defenderRobotId, attacker, _attackerRobotId);
        }

        delete ds.arenas[_arenaId];        
    }

    // Returns true if an attacker is a winner, false if a defender
    function _fighting(address _nft, uint256 _defenderRobotId, uint256 _attackerRobotId, uint128 _arenaId) internal view returns (bool) {
        (uint8 defenderAttack, uint8 defenderDefence,) = IRobotsNFT(_nft).getStats(_defenderRobotId);
        (uint8 attackerAttack, uint8 attackerDefence,) = IRobotsNFT(_nft).getStats(_attackerRobotId);
        uint256 winner = 1;

        if (attackerAttack > defenderDefence) {
            unchecked {++winner;} // max can only be 2
        } 
        if (defenderAttack > attackerDefence) {
            unchecked {--winner;} // min can only be 0
        }
        if (winner == 2) return true; // only the attacker won
        if (winner == 0) return false; // only the defender won
        
        // If both won or both lost pseudorandom decides the winner
        uint256 rand = uint256(keccak256(abi.encodePacked(_defenderRobotId, _attackerRobotId, _arenaId, blockhash(block.number - 1)))) % 2;
        return rand == 0 ? true : false;
    }
}