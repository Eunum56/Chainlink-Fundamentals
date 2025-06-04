# 🚀 Automation Project

This repository showcases multiple Chainlink Automation projects demonstrating different use cases: Custom Logic, Log Trigger, and Time-based automation.

---

## 🗂️ Folder Structure

```
Automation/
├── Custom Logic/
│   ├── AutoToken.sol
│   └── MintingController.sol
├── Log Trigger/
│   ├── LogNFT.sol
│   ├── LogToken.sol
│   └── TransferAutomation.sol
└── Time-based/
    └── SimpleCounter.sol
```

---

## 📚 Overview
This project is a learning playground for experimenting with Chainlink Automation on Ethereum networks using Foundry. Each sub-folder demonstrates a different automation technique:

---


## ✨ Custom Logic Automation

**Contracts:**

- **AutoToken**
  - ERC20 token with controlled minting via automation.
  - **Deployed at:** `0x8047b4B07d1597Fbc158fD57A638636d8190A8f1`

- **MintingController**
  - Manages minting logic for AutoToken via Chainlink Automation.
  - **Deployed at:** `0xe2bB3C5074A85fe87CbE63DFc16d9802F6AbAD49`

**Features:**
- Custom logic implementation to allow automated token minting based on defined conditions.
- Chainlink Automation integration to manage token issuance automatically.
- Fully tested with high coverage using Forge Coverage.

---

## ✨ Log Trigger Automation

**Contracts:**

- **LogNFT**
  - ERC721 NFT that emits a `TransferTriggered` event on transfer.
  - **Deployed at:** `0x69B5B693e55a28430849F507A94eB6415D5F7D1A`

- **LogToken**
  - ERC20 token that rewards NFT holders upon transfers.
  - **Deployed at:** `0xDD4a92f9616bE830b6271c5e716E4C645834cd0d`

- **TransferAutomation**
  - Listens to NFT transfer events and rewards tokens automatically via Chainlink Automation.
  - **Deployed at:** `0xEe91d0F12e21a6cFBFA919baBc968F1A2e8BAb23`

**Features:**
- Automatic token rewards on NFT transfers using Chainlink Log Trigger Automation.
- Real-world event-based logic that incentivizes NFT activity.
- Fully tested with Forge Coverage.

---

## ⏱️ Time-based Automation

**Contracts:**

- **SimpleCounter**
  - A simple time-based contract using Chainlink Keepers to increment a counter on schedule.

**Features:**
- Demonstrates cron-like scheduling with Chainlink Automation.
- Fully tested with Forge Coverage.

---

## 🔗 Summary

All contracts are deployed on Ethereum Sepolia, verified on Etherscan, and fully tested with Forge Coverage. For more details, please refer to each contract’s directory.

---

## 📌 Notes
 - Deployed contracts are verified on Etherscan.

 - Always double-check function names (e.g. `checkUpkeep`, `performUpkeep`, `checkLog`, `TransferTriggered`).

- Use **Chainlink Automation UI** to configure triggers and check logs.

---

## 👨‍💻 Author

**Mohammed Muzammil**  
Smart Contract Developer & Automation Enthusiast
