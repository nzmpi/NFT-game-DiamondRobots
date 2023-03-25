# Diamond Robots [NFT game]

A new version of [the Robots game](https://github.com/nzmpi/NFT-game-robots) that 
uses [EIP-2535](https://eips.ethereum.org/EIPS/eip-2535).

## About

- This game uses EIP-2535 (Diamond), that allows to add, remove and replace functions separately from each other.

- All contracts are in [facets](https://github.com/nzmpi/NFT-game-DiamondRobots/tree/main/facets) folder.

## Contracts

### Deployer

`Deployer.sol` deploys the game with basic facets. Then call 

### V2

This contract is an example of an update of the game.

 - V2 inherits Fighting.
 - Provides a new way to generate 'dna' (but it's still *pseudorandom*).
 - Updating the game will keep all the values and mappings of the old contract.

