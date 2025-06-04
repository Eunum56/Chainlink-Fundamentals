# Chainlink Fundamentals Repository

Welcome to my Chainlink learning repository! 🚀 This project serves as a hands-on exploration of different Chainlink services and features, each demonstrated through practical smart contract projects. As I dive deeper into Chainlink, I'll continue adding new services, example contracts, and tests.

## 📚 Overview

This repository is organized by Chainlink service categories. Each service folder contains example projects that demonstrate real-world use cases.

### 📁 Repository Structure

```

chainlink-fundamentals/
├── script/
│   ├── Automation/
│   ├── CCIP/
│   ├── Data Feeds/
│   ├── Functions/
│   └── VRF/
├── src/
│   ├── Automation/
│   ├── CCIP/
│   ├── Data Feeds/
│   ├── Functions/
│   └── VRF/
├── test/
│   ├── Automation/
│   ├── CCIP/
│   ├── Data Feeds/
│   ├── Functions/
│   └── VRF/
├── .env.example
├── .gitignore
├── .gitmodules
├── foundry.toml
├── LICENSE
└── README.md
```

---


## 🗂️ How This Repo Works

- Each **Chainlink service or feature** has its own folder under `src/`, `script/` and `test/`.
- Inside each feature folder, you’ll find **example projects or contracts** that demonstrate how to use that Chainlink feature.
- Tests are organized alongside each feature for easy testing and understanding.

---

## 🛠️ Services & Example Projects

### 1️⃣ Data Feeds

**Description:**  
Chainlink Data Feeds bring reliable, tamper-proof real-world data (like asset prices) on-chain.

**Example Project:**  
- **GameToken (Price Feeds)**  
  - **Description:**  
    - A dynamic token minting system where the number of tokens minted depends on the current ETH/USD price from Chainlink’s Price Feed.
    - The `GameEngine.sol` contract interacts with Chainlink’s decentralized price oracles, ensuring the token minting process remains transparent and secure.
  - **Files:**  
    - `GameEngine.sol` – Handles token minting logic based on live price data.
    - `GameToken.sol` – The ERC20 token contract.

---

### 2️⃣ Automation

**Description:**  
Chainlink Automation allows smart contracts to perform scheduled or condition-based tasks automatically, removing the need for manual intervention.

**Example Projects:**  
- **Time-based Automation**  
  - **Description:**  
    - Demonstrates cron-like scheduling using Chainlink Automation.
    - Contract: `SimpleCounter.sol`
    - Features: Periodic counter increment using scheduled automation.

- **Custom Logic Automation**  
  - **Description:**  
    - Automates token minting based on custom logic.
    - Contracts: `AutoToken.sol`, `MintingController.sol`
    - Features: Automated token issuance based on defined on-chain conditions.

- **Log Trigger Automation**  
  - **Description:**  
    - Automates token rewards on NFT transfers using on-chain events.
    - Contracts: `LogNFT.sol`, `LogToken.sol`, `TransferAutomation.sol`
    - Features: Real-world event-driven automation that rewards NFT activity.

---


### 3️⃣ CCIP (Cross-Chain Interoperability Protocol)

**Description:**
CCIP enables secure cross-chain messaging and token transfers, facilitating interoperability between blockchains.

**Planned Projects:**
- Cross-chain asset bridge.
- Cross-chain game state synchronization.

---

### 4️⃣ VRF (Verifiable Random Function)

**Description:**
Chainlink VRF provides provably fair and verifiable randomness, essential for gaming, lotteries, and any application that requires unbiased outcomes.

**Planned Projects:**
- On-chain lottery system with fair winner selection.
- Random NFT minting (generative art).

---

### 5️⃣ Functions

**Description:**
Chainlink Functions enable fetching off-chain data or performing off-chain computations that are brought on-chain securely.

**Planned Projects:**
- Weather-based insurance payouts.
- Dynamic NFT metadata using external APIs.

---

## 🚀 Getting Started

1. **Clone the repository:**

   ```bash
   git clone https://github.com/Eunum56/Chainlink-Fundamentals
   cd chainlink-fundamentals
   ```

2. **Install dependencies (Foundry):**

   ```bash
   forge install
   ```

3. **Configure environment variables:**

   * Copy `.env.example` to `.env` and update your variables (e.g., RPC URLs, private keys).


4. **Build the project:**

   ```bash
   forge build
   ```


5. **Run tests:**

   ```bash
   forge test
   ```

---

## 🧩 Technologies Used

* **Solidity** — Smart contract development
* **Foundry** — Compilation, testing, and deployment framework
* **Chainlink** — Decentralized services and oracles

---

## 📌 Notes

- This repository is focused on **learning and exploration**.
- Project ideas may evolve over time as I explore Chainlink features more deeply.
- Each project aims to demonstrate a practical use case or concept, but may differ in complexity and scope.

---

## 📝 Contributing

This repository is intended as a personal learning space, but contributions, suggestions, or feedback are always welcome. Feel free to fork, submit issues, or open PRs to collaborate.

---

## 📄 License

This project licensed under MIT License. See the (LICENSE)[LICENSE] for details.

---

## 🙌 Acknowledgements

* Chainlink documentation and workshops
* Cyfrin Updraft course
* Community tutorials and GitHub examples

Stay tuned for more projects as I continue learning! 🚀