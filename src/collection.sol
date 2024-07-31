// SPDX-License-Identifier: MIT LICENSE

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity 0.8.24;

/**
 * @title Collection
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation with additional features
 */
contract Collection is ERC721Enumerable, Ownable {
    using Strings for uint256;

    /// @notice Base URI for the metadata
    string public baseURI;
    /// @notice Extension for the metadata files
    string public baseExtension = ".json";
    /// @notice Maximum supply of tokens
    uint256 public maxSupply = 100000;
    /// @notice Maximum number of tokens that can be minted in one transaction
    uint256 public maxMintAmount = 5;
    /// @notice Boolean to control minting state
    bool public paused = false;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection,
     * and transferring ownership to `initialOwner`.
     */
    constructor(
        string memory name,
        string memory symbol,
        address initialOwner
    ) ERC721(name, symbol) Ownable(initialOwner) {}

    /**
     * @dev Internal function to return the base URI for all token IDs.
     * @return Base URI string
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://QmYB5uWZqfunBq7yWnamTqoXWBAHiQoirNLmuxMzDThHhi/";
    }

    /**
     * @notice Mints `mintAmount` tokens and transfers them to `_to`.
     * @param _to The address to mint tokens to.
     * @param _mintAmount The number of tokens to mint.
     */
    function mint(address _to, uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();

        // Ensure the minting process is not paused
        require(!paused, "Minting is paused");
        // Ensure the mint amount is more than 0
        require(_mintAmount > 0, "Mint amount must be greater than 0");
        // Ensure the mint amount does not exceed the max mint amount per transaction
        require(
            _mintAmount <= maxMintAmount,
            "Mint amount exceeds max mint amount"
        );
        // Ensure the total supply does not exceed the max supply
        require(
            supply + _mintAmount <= maxSupply,
            "Mint amount exceeds max supply"
        );

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(_to, supply + i);
        }
    }

    /**
     * @notice Returns a list of token IDs owned by `_owner`.
     * @param _owner The address to query.
     * @return Array of token IDs owned by `_owner`
     */
    function walletOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    /**
     * @notice Returns the token URI for a given `tokenId`.
     * @param tokenId The token ID to query.
     * @return Token URI string
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    // Only owner functions

    /**
     * @notice Sets a new maximum mint amount per transaction.
     * @param _newmaxMintAmount The new maximum mint amount.
     */
    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    /**
     * @notice Sets a new base URI for the metadata.
     * @param _newBaseURI The new base URI string.
     */
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    /**
     * @notice Sets a new base extension for the metadata files.
     * @param _newBaseExtension The new base extension string.
     */
    function setBaseExtension(
        string memory _newBaseExtension
    ) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    /**
     * @notice Pauses or unpauses the minting process.
     * @param _state The new state of the pause.
     */
    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    /**
     * @notice Withdraws the contract's balance to the owner's address.
     */
    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}
