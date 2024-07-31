// SPDX-License-Identifier: MIT LICENSE

pragma solidity 0.8.24;

import "./rewards.sol";
import "./collection.sol";

/**
 * @title NFTStaking
 * @dev A contract to stake NFTs and earn rewards tokens.
 */
contract NFTStaking is Ownable {
    struct vaultInfo {
        Collection nft;
        N2DRewards token;
        string name;
    }

    vaultInfo[] public VaultInfo;

    // Struct to store a stake's token, owner, and earning values
    struct Stake {
        uint24 tokenId;
        uint48 timestamp;
        address owner;
    }

    uint256 public totalStaked;
    mapping(uint256 => Stake) public vault;

    event NFTStaked(address owner, uint256 tokenId, uint256 value);
    event NFTUnstaked(address owner, uint256 tokenId, uint256 value);
    event Claimed(address owner, uint256 amount);

    /**
     * @dev Initializes the contract by setting the initial owner.
     * @param initialOwner Address of the initial owner.
     */
    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @dev Adds a new vault to the contract.
     * @param _nft The NFT collection associated with the vault.
     * @param _token The rewards token associated with the vault.
     * @param _name The name of the vault.
     */
    function addVault(
        Collection _nft,
        N2DRewards _token,
        string calldata _name
    ) public {
        VaultInfo.push(vaultInfo({nft: _nft, token: _token, name: _name}));
    }

    /**
     * @dev Stakes NFTs in a specific vault.
     * @param _pid The vault ID.
     * @param tokenIds The array of token IDs to be staked.
     */
    function stake(uint256 _pid, uint256[] calldata tokenIds) external {
        uint256 tokenId;
        totalStaked += tokenIds.length;
        vaultInfo storage vaultid = VaultInfo[_pid];

        for (uint i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            // Ensure the sender owns the token
            require(
                vaultid.nft.ownerOf(tokenId) == msg.sender,
                "not your token"
            );
            // Ensure the token is not already staked
            require(vault[tokenId].tokenId == 0, "already staked");

            // Transfer the NFT to the staking contract
            vaultid.nft.transferFrom(msg.sender, address(this), tokenId);
            emit NFTStaked(msg.sender, tokenId, block.timestamp);

            // Record the stake
            vault[tokenId] = Stake({
                owner: msg.sender,
                tokenId: uint24(tokenId),
                timestamp: uint48(block.timestamp)
            });
        }
    }

    /**
     * @dev Internal function to unstake multiple NFTs.
     * @param account The address of the token owner.
     * @param tokenIds The array of token IDs to be unstaked.
     * @param _pid The vault ID.
     */
    function _unstakeMany(
        address account,
        uint256[] calldata tokenIds,
        uint256 _pid
    ) internal {
        uint256 tokenId;
        totalStaked -= tokenIds.length;
        vaultInfo storage vaultid = VaultInfo[_pid];

        for (uint i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            // Ensure the sender is the owner of the token
            require(staked.owner == msg.sender, "not an owner");

            // Remove the stake record
            delete vault[tokenId];
            emit NFTUnstaked(account, tokenId, block.timestamp);

            // Transfer the NFT back to the owner
            vaultid.nft.transferFrom(address(this), account, tokenId);
        }
    }

    /**
     * @dev Claims rewards for the staked NFTs without unstaking them.
     * @param tokenIds The array of token IDs to claim rewards for.
     * @param _pid The vault ID.
     */
    function claim(uint256[] calldata tokenIds, uint256 _pid) external {
        _claim(msg.sender, tokenIds, _pid, false);
    }

    /**
     * @dev Claims rewards for the staked NFTs for a specific address without unstaking them.
     * @param account The address of the token owner.
     * @param tokenIds The array of token IDs to claim rewards for.
     * @param _pid The vault ID.
     */
    function claimForAddress(
        address account,
        uint256[] calldata tokenIds,
        uint256 _pid
    ) external {
        _claim(account, tokenIds, _pid, false);
    }

    /**
     * @dev Unstakes NFTs and optionally claims rewards.
     * @param tokenIds The array of token IDs to be unstaked.
     * @param _pid The vault ID.
     */
    function unstake(uint256[] calldata tokenIds, uint256 _pid) external {
        _claim(msg.sender, tokenIds, _pid, true);
    }

    /**
     * @dev Internal function to claim rewards and optionally unstake NFTs.
     * @param account The address of the token owner.
     * @param tokenIds The array of token IDs to claim rewards for.
     * @param _pid The vault ID.
     * @param _unstake Whether to unstake the NFTs after claiming rewards.
     */
    function _claim(
        address account,
        uint256[] calldata tokenIds,
        uint256 _pid,
        bool _unstake
    ) internal {
        uint256 tokenId;
        uint256 earned = 0;
        vaultInfo storage vaultid = VaultInfo[_pid];

        for (uint i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Stake memory staked = vault[tokenId];
            // Ensure the sender is the owner of the token
            require(staked.owner == account, "not an owner");

            // Calculate earned rewards
            uint256 stakedAt = staked.timestamp;
            earned += (100000 ether * (block.timestamp - stakedAt)) / 1 days;

            // Update the stake timestamp
            vault[tokenId] = Stake({
                owner: account,
                tokenId: uint24(tokenId),
                timestamp: uint48(block.timestamp)
            });
        }

        if (earned > 0) {
            earned = earned / 10;
            vaultid.token.mint(account, earned);
        }

        if (_unstake) {
            _unstakeMany(account, tokenIds, _pid);
        }

        emit Claimed(account, earned);
    }

    /**
     * @dev Returns the earning information for a specific stake.
     * @return An array with the total earned amount and the earning rate per second.
     */
    function earningInfo() external view returns (uint256[2] memory) {
        uint256 tokenId;
        uint256 totalScore = 0;
        uint256 earned = 0;
        Stake memory staked = vault[tokenId];
        uint256 stakedAt = staked.timestamp;
        earned += (100000 ether * (block.timestamp - stakedAt)) / 1 days;
        uint256 earnRatePerSecond = (totalScore * 1 ether) / 1 days;
        earnRatePerSecond = earnRatePerSecond / 100000;
        // earned, earnRatePerSecond
        return [earned, earnRatePerSecond];
    }

    /**
     * @dev Returns the balance of staked NFTs for a specific address in a specific vault.
     * @param account The address to query the balance for.
     * @param _pid The vault ID.
     * @return The balance of staked NFTs.
     */
    function balanceOf(
        address account,
        uint256 _pid
    ) public view returns (uint256) {
        uint256 balance = 0;
        vaultInfo storage vaultid = VaultInfo[_pid];
        uint256 supply = vaultid.nft.totalSupply();

        for (uint i = 1; i <= supply; i++) {
            if (vault[i].owner == account) {
                balance += 1;
            }
        }

        return balance;
    }

    /**
     * @dev Returns an array of token IDs owned by a specific address in a specific vault.
     * @param account The address to query the tokens for.
     * @param _pid The vault ID.
     * @return  An array of token IDs owned by the specified address.
     */
    function tokensOfOwner(
        address account,
        uint256 _pid
    ) public view returns (uint256[] memory) {
        vaultInfo storage vaultid = VaultInfo[_pid];
        uint256 supply = vaultid.nft.totalSupply();
        uint256[] memory tmp = new uint256[](supply);

        uint256 index = 0;
        for (uint tokenId = 1; tokenId <= supply; tokenId++) {
            if (vault[tokenId].owner == account) {
                tmp[index] = vault[tokenId].tokenId;
                index += 1;
            }
        }

        uint256[] memory tokens = new uint256[](index);
        for (uint i = 0; i < index; i++) {
            tokens[i] = tmp[i];
        }

        return tokens;
    }
}
