// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    // Structure to represent an in-game item
    struct GameItem {
        uint256 itemId;
        string itemName;
        uint256 itemCost;
    }

    GameItem[] public gameItems; // List of in-game items

    // Mapping to store owned items for each address
    mapping(address => GameItem[]) private ownedItems;

    constructor() ERC20("Degen", "DGN") Ownable() {
        // Initialize some game items with different values
        gameItems.push(GameItem(1, "Lord Regi'S Humongous Sword", 26));
        gameItems.push(GameItem(2, "Shield of Binan", 69));
        gameItems.push(GameItem(3, "Pandemonium Potion", 77));
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 0; // No fractional tokens
    }

    function getBalance() external view returns (uint256) {
        return this.balanceOf(msg.sender);
    }

    function burnTokens(uint256 amount) public {
        require(
            balanceOf(_msgSender()) >= amount,
            "You do not have enough Degen Tokens"
        );
        _burn(_msgSender(), amount);
    }

    function transferTokens(address recipient, uint256 amount) external {
        require(
            balanceOf(_msgSender()) >= amount,
            "Transfer failed: insufficient balance"
        );
        approve(msg.sender, amount);
        transferFrom(msg.sender, recipient, amount);
    }

    // Redeem tokens for a specific game item
    function redeem(uint256 itemId) external {
        require(itemId > 0 && itemId <= gameItems.length, "Invalid item ID");
        GameItem memory item = gameItems[itemId - 1]; // Adjust index (1-based ID)

        require(
            balanceOf(msg.sender) >= item.itemCost,
            "Insufficient balance to redeem"
        );

        _burn(msg.sender, item.itemCost);

        // Add the item to the user's owned items
        ownedItems[msg.sender].push(item);

        // Emit an event for the redemption
        emit ItemRedeemed(
            msg.sender,
            item.itemId,
            item.itemName,
            item.itemCost
        );
    }

    // Fetch all available game items
    function getGameItems() external view returns (GameItem[] memory) {
        return gameItems;
    }

    // Fetch owned items for the caller
    function getOwnedItems() external view returns (GameItem[] memory) {
        return ownedItems[msg.sender];
    }

    // Event to log redemption
    event ItemRedeemed(
        address indexed redeemer,
        uint256 itemId,
        string itemName,
        uint256 itemCost
    );
}

