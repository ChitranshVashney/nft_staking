## NFTStaking Smart Contract

The NFTStaking smart contract allows users to stake their NFTs in return for rewards in the form of tokens. Below is an explanation of the contract's structure and functionality.

### Contract Structure

#### VaultInfo

- vaultInfo Struct: This struct holds information about each vault which includes:
  - Collection nft: The NFT contract associated with the vault.
  - N2DRewards token: The rewards token contract associated with the vault.
  - string name: The name of the vault.

#### Stake

- Stake Struct: This struct represents a staked NFT, storing:
  - uint24 tokenId: The ID of the staked token.
  - uint48 timestamp: The timestamp when the NFT was staked.
  - address owner: The address of the owner who staked the NFT.

#### State Variables

- VaultInfo[] public VaultInfo: An array that stores the information of all vaults.
- uint256 public totalStaked: Keeps track of the total number of NFTs staked.
- mapping(uint256 => Stake) public vault: Maps token IDs to their corresponding stake information.

#### Events

- NFTStaked(address owner, uint256 tokenId, uint256 value): Emitted when an NFT is staked.
- NFTUnstaked(address owner, uint256 tokenId, uint256 value): Emitted when an NFT is unstaked.
- Claimed(address owner, uint256 amount): Emitted when rewards are claimed.

#### Constructor

```javascript
 constructor(address initialOwner) Ownable(initialOwner) {}
```

- Sets the initial owner of the contract.

#### Functions

- addVault: Adds a new vault with the given NFT contract, token contract, and name.

```javascript
function addVault(Collection _nft, N2DRewards _token, string calldata _name) public;
```

- stake:
  - Allows users to stake multiple NFTs by specifying the vault ID (\_pid) and an array of token IDs (tokenIds).
  - Transfers the NFTs from the user to the contract and records the stake information.

```javascript
function stake(uint256 _pid, uint256[] calldata tokenIds) external;
```

- \_unstakeMany
  - Transfers the NFTs back to the user and removes the stake information.
  - Internal function to unstake multiple NFTs.

```javascript
function _unstakeMany(address account, uint256[] calldata tokenIds, uint256 _pid) internal;
```

- claim
  - Allows users to claim rewards for their staked NFTs by specifying the vault ID (\_pid) and an array of token IDs (tokenIds).

```javascript
function claim(uint256[] calldata tokenIds, uint256 _pid) external;
```

- claimForAddress
  - Allows an external address to claim rewards on behalf of another user.

```javascript
function claimForAddress(address account, uint256[] calldata tokenIds, uint256 _pid) external;
```

- unstake
  - Allows users to unstake their NFTs and claim their rewards simultaneously.

```javascript
function unstake(uint256[] calldata tokenIds, uint256 _pid) external;
```

- \_claim
  - Internal function to claim rewards for staked NFTs.
    Calculates the rewards earned based on the staking duration and mints the reward tokens.
  - If \_unstake is true, the NFTs are also unstaked.

```javascript
function _claim(address account, uint256[] calldata tokenIds, uint256 _pid, bool _unstake) internal;
```

- earningInfo
  - Returns the total earned rewards and the earning rate per second for a specific staked NFT.

```javascript
function earningInfo() external view returns (uint256[2] memory info);
```

- balanceOf
  - Returns the number of NFTs staked by a specific user in a specific vault.

```javascript
function balanceOf(address account, uint256 _pid) public view returns (uint256);
```

- tokensOfOwner
  - Returns an array of token IDs staked by a specific user in a specific vault.

```javascript
function tokensOfOwner(address account, uint256 _pid) public view returns (uint256[] memory ownerTokens);
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployNFTStaking.s.sol --broadcast --rpc-url <YOUR_RPC_URL> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
