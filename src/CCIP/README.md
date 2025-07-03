# FlexiToken Cross-Chain CCIP Project

This project demonstrates a complete cross-chain token bridging system using **Chainlink CCIP**.

## 📦 Contracts & Tests

### 🧱 Main Contracts

- **FlexiToken** — a custom mintable/burnable ERC20 token.
- **FlexiTokenPool** — a CCIP-compatible token pool that handles bridging logic.
- **Vault** — an auxiliary contract that can mint/burn tokens for internal use cases.

### 🧪 Tests

All smart contracts are covered by unit and fuzz tests:

- **`FlexiTokenUnit.t.sol`** — covers core token behavior, mint/burn permissions, and ERC20 compliance.
- **`CrossChainUnit.t.sol`** — tests cross-chain pool logic, registry setup, and CCIP interactions.
- **`FlexiTokenFuzz.t.sol`** — performs fuzzing on token minting, burning, and role management to catch edge cases.

## ⚙️ Deployment

Dedicated deployment and configuration scripts are written to:

- Deploy FlexiToken, FlexiTokenPool, and Vault on multiple chains.
- Register the token and pool with Chainlink CCIP.
- Configure allowed remote pools and chain selectors.
- Perform bridging operations using the Chainlink CCIP Router.

## 🔗 CCIP Setup

This project uses:
- **TokenAdminRegistry** for managing token admin roles.
- **RegistryModuleOwnerCustom** for custom admin registration.
- **CCIP Router** for sending cross-chain messages and token transfers.
