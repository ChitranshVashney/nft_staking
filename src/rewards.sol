// SPDX-License-Identifier: MIT LICENSE

pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @title N2DRewards
 * @dev An ERC20 token with additional features: minting, burning, and controller management.
 */
contract N2DRewards is ERC20, ERC20Burnable, Ownable {
    // Mapping to track addresses that are allowed to mint tokens
    mapping(address => bool) controllers;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     * @param name Token name.
     * @param symbol Token symbol.
     * @param initialOwner Initial owner of the contract.
     */
    constructor(
        string memory name,
        string memory symbol,
        address initialOwner
    ) ERC20(name, symbol) Ownable(initialOwner) {}

    /**
     * @notice Mint new tokens.
     * @dev Only addresses in the controllers mapping can call this function.
     * @param to The address to receive the newly minted tokens.
     * @param amount The number of tokens to be minted.
     */
    function mint(address to, uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");
        _mint(to, amount);
    }

    /**
     * @notice Burn tokens from a specific account.
     * @dev If the caller is a controller, they can burn tokens directly from an account.
     * @param account The account whose tokens will be burned.
     * @param amount The number of tokens to be burned.
     */
    function burnFrom(address account, uint256 amount) public override {
        if (controllers[msg.sender]) {
            _burn(account, amount);
        } else {
            super.burnFrom(account, amount);
        }
    }

    /**
     * @notice Add a new controller.
     * @dev Only the owner can add new controllers.
     * @param controller The address to be added as a controller.
     */
    function addController(address controller) external onlyOwner {
        controllers[controller] = true;
    }

    /**
     * @notice Remove a controller.
     * @dev Only the owner can remove controllers.
     * @param controller The address to be removed as a controller.
     */
    function removeController(address controller) external onlyOwner {
        controllers[controller] = false;
    }

    function getController(address controller) external view returns (bool) {
        return controllers[controller];
    }
}
