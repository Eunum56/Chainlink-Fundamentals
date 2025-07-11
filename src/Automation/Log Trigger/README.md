# ✨ Log Trigger Automation

This project rewards NFT activity by minting tokens whenever an NFT transfer occurs.

## 🚀 Contracts

- **LogNFT**
  - ERC721 NFT contract.
  - Deployed at: `0x69B5B693e55a28430849F507A94eB6415D5F7D1A`

- **LogToken**
  - ERC20 reward token.
  - Deployed at: `0xDD4a92f9616bE830b6271c5e716E4C645834cd0d`

- **TransferAutomation**
  - Chainlink Automation contract that listens to NFT transfers and mints rewards.
  - Deployed at: `0xEe91d0F12e21a6cFBFA919baBc968F1A2e8BAb23`

  ## ✅ Test Coverage

| File | Statements | Branches | Functions | Lines |
| ---- | ---------- | -------- | --------- | ----- |
| `src/Automation/Log Trigger/LogNFT.sol` | 100.00% (20/20) | 100.00% (14/14) | 100.00% (2/2) | 100.00% (6/6) |
| `src/Automation/Log Trigger/LogToken.sol` | 100.00% (21/21) | 100.00% (14/14) | 100.00% (4/4) | 100.00% (7/7) |
| `src/Automation/Log Trigger/TransferAutomation.sol` | 100.00% (17/17) | 100.00% (14/14) | 100.00% (1/1) | 100.00% (5/5) |


## 🔗 Features

- Chainlink Log Trigger Automation integration.
- Rewards NFT transfers by minting tokens.
- Fully tested with Forge Coverage.

## 🔎 Notes

- Contracts are deployed, verified, and 100% tested.
