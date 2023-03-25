# Diamond Robots [NFT game]

A new version of [the Robots game](https://github.com/nzmpi/NFT-game-robots) that 
uses [EIP-2535](https://eips.ethereum.org/EIPS/eip-2535).

## About

- This game uses EIP-2535 (Diamond), that allows to add, remove and replace functions separately from each other.
- All contracts are in the [facets](https://github.com/nzmpi/NFT-game-DiamondRobots/tree/main/facets) folder.
- The game now also allows to change the NFT.

## Contracts

### Deployer

Use `Deployer.sol` to deploy the game with basic facets. 
Then call `deployFacets(address _token, address _nft)` to deploy other facets, 
add new functions and initialize the game.

EOA that deploys this contract becomes the owner of the game.

### Admin

`Admin.sol` helps to administrate the game as an owner of the game:

 - Allows to change addresses of the NFT and reward token.
 - Allows to change fees, taxes and other variables.
 - Allows to withdraw eth and tokens from the game. 
 - Allows to transfer the ownership of the game.
 - Allows to add, remove and replace functions from the game.

### User

`User.sol` is an example of the user account.

### FacetV2

`FacetV2.sol` is an example of an update of the game.

 - Has a new function that returns double of the market tax.
 - Has a new `mintRobotWithToken()` function that doesn't restrict minting.

## Beware!

The game uses tx.origin and not msg.sender to check the owner.
So, only use the owner's account to interact with the game. 

**Beware of phishing attacks!**
 



