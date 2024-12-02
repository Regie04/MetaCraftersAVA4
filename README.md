# DegenToken Smart Contract

## Overview

The `DegenToken` contract is an ERC20 token integrated with a simple in-game item redemption system. Players can mint tokens, transfer tokens, burn tokens, and redeem tokens for in-game items. The contract is designed to work within a gaming ecosystem, where tokens serve as the currency for acquiring various game items. The system supports a list of pre-defined game items with different costs and allows players to redeem tokens for these items.

## Features

- **ERC20 Token**: Implements the ERC20 standard for fungible tokens.
- **Minting**: Only the contract owner can mint new tokens.
- **Token Transfers**: Players can transfer tokens to other players.
- **Burning**: Players can burn their tokens to reduce their balance.
- **Item Redemption**: Players can redeem their tokens for in-game items.
- **Game Items**: The contract comes with a predefined list of game items with unique IDs, names, and costs.
- **Item Ownership**: Players' redeemed items are tracked and stored privately for each address.

## Contract Details

### Token Name: `Degen`
### Token Symbol: `DGN`
### Decimals: 0 (no fractional tokens)

### Predefined Game Items:
- **Lord Regi'S Humongous Sword**: Cost 26 Degen Tokens
- **Shield of Binan**: Cost 69 Degen Tokens
- **Pandemonium Potion**: Cost 77 Degen Tokens

## Functions

### `mint(address to, uint256 amount)`
- Mints new tokens and assigns them to the `to` address.
- **Access Control**: Only the contract owner can mint new tokens.

### `decimals()`
- Returns the number of decimal places for the token (0 in this case).

### `getBalance()`
- Returns the balance of Degen Tokens for the caller (msg.sender).

### `burnTokens(uint256 amount)`
- Burns a specific amount of tokens from the caller's balance.

### `transferTokens(address recipient, uint256 amount)`
- Transfers a specified amount of tokens to the recipient address.
- Approves the transaction before transferring the tokens.

### `redeem(uint256 itemId)`
- Redeems tokens for a specific in-game item.
- The caller must have enough tokens to cover the cost of the item.

### `getGameItems()`
- Returns an array of all available game items.

### `getOwnedItems()`
- Returns an array of items owned by the caller (msg.sender).

## Events

### `ItemRedeemed(address indexed redeemer, uint256 itemId, string itemName, uint256 itemCost)`
- Emitted when a player successfully redeems tokens for an item.

## Author

- **Github**: @Regie04
- **Email**: sanchezreginald4@gmail.com
- **Name**: Reginald Carl Sanchez

## Example Code

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    struct GameItem {
        uint256 itemId;
        string itemName;
        uint256 itemCost;
    }

    GameItem[] public gameItems;
    mapping(address => GameItem[]) private ownedItems;

    constructor() ERC20("Degen", "DGN") Ownable() {
        gameItems.push(GameItem(1, "Lord Regi'S Humongous Sword", 26));
        gameItems.push(GameItem(2, "Shield of Binan", 69));
        gameItems.push(GameItem(3, "Pandemonium Potion", 77));
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function getBalance() external view returns (uint256) {
        return this.balanceOf(msg.sender);
    }

    function burnTokens(uint256 amount) public {
        require(balanceOf(_msgSender()) >= amount, "You do not have enough Degen Tokens");
        _burn(_msgSender(), amount);
    }

    function transferTokens(address recipient, uint256 amount) external {
        require(balanceOf(_msgSender()) >= amount, "Transfer failed: insufficient balance");
        approve(msg.sender, amount);
        transferFrom(msg.sender, recipient, amount);
    }

    function redeem(uint256 itemId) external {
        require(itemId > 0 && itemId <= gameItems.length, "Invalid item ID");
        GameItem memory item = gameItems[itemId - 1];
        require(balanceOf(msg.sender) >= item.itemCost, "Insufficient balance to redeem");
        _burn(msg.sender, item.itemCost);
        ownedItems[msg.sender].push(item);
        emit ItemRedeemed(msg.sender, item.itemId, item.itemName, item.itemCost);
    }

    function getGameItems() external view returns (GameItem[] memory) {
        return gameItems;
    }

    function getOwnedItems() external view returns (GameItem[] memory) {
        return ownedItems[msg.sender];
    }

    event ItemRedeemed(address indexed redeemer, uint256 itemId, string itemName, uint256 itemCost);
}
