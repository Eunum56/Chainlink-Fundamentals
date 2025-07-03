# Chainlink Fundamentals Repository

Welcome to my Chainlink learning repository! 🚀 This project serves as a hands-on exploration of different Chainlink services and features, each demonstrated through practical smart contract projects. As I dive deeper into Chainlink, I'll continue adding new services, example contracts, and tests.

## 📚 Overview

This repository is organized by Chainlink service categories. Each service folder contains example projects that demonstrate real-world use cases.

### 📁 Repository Structure

```

chainlink-fundamentals/
├── script/
│   ├── Data Feeds/
│   ├── Automation/
│   ├── VRF/
|   ├── Data Streams/
│   ├── Functions/
│   └── CCIP/
├── src/
│   ├── Data Feeds/
│   ├── Automation/
│   ├── VRF/
|   ├── Data Streams/
│   ├── Functions/
│   └── CCIP/
├── test/
│   ├── Data Feeds/
│   ├── Automation/
│   ├── VRF/
|   ├── Data Streams/
│   ├── Functions/
│   └── CCIP/
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

### 3️⃣ VRF (Verifiable Random Function)

**Description:**  
Chainlink VRF provides secure, tamper-proof randomness on-chain, essential for use cases like gaming, NFT minting, or lotteries.

**Example Project:**  
- **Random Number Generator**  
  - **Description:**  
    - A Solidity smart contract that uses Chainlink VRF to generate provably fair random numbers on-chain.
    - Users can request a random number, which is securely delivered via an asynchronous callback and stored per user.
  - **Contracts:**  
    - `RandomNumberGenerator.sol`
  - **Features:**  
    - Secure random number requests.
    - Handles asynchronous callbacks with `fulfillRandomWords()`.
    - Stores randomness per user.
    - Emits events for request and fulfillment.
    - Supports multiple chains via helper configuration.

---

### 4️⃣ Data Streams

**Description:**  
Chainlink Data Streams provide low-latency, high-frequency data for advanced DeFi use cases, such as perpetuals, derivatives, and high-speed oracles.

**Example Project:**  
- **Log-Triggered Price Capture**  
  - **Description:**  
    - A smart contract system that emits logs to trigger Chainlink Automation, which fetches real-time ETH/USD price from Chainlink Data Streams and stores it on-chain.
    - Demonstrates how on-chain events can drive high-speed data pipelines using Chainlink's Streams and Automation.
  - **Contracts:**  
    - `LogEmitter.sol` – Emits a log to initiate the data flow.  
    - `StreamsUpkeep.sol` – Handles log verification and price capture via `StreamsLookup`.  
  - **Features:**  
    - Uses Log Triggered Automation.
    - Fetches and stores low-latency price data.
    - Simulates real-time DeFi use cases.

---

### 5️⃣ Functions

**Description:**  
Chainlink Functions enable fetching off-chain data or performing off-chain computations that are brought on-chain securely.

**Example Project:**  
- **TopCryptoDetails (CoinGecko Integration)**  
  - **Description:**  
    - A smart contract that uses Chainlink Functions to fetch live data from CoinGecko about the top N cryptocurrencies by market cap.
    - Entirely built using Foundry — no manual Chainlink UI interactions required.
  - **Contracts:**  
    - `TopCryptoDetails.sol` – Sends requests and stores off-chain API responses.  
  - **Scripts:**  
    - Fully automated setup scripts for creating subscriptions, funding them, adding consumers, and making requests — all via Foundry.
  - **Features:**  
    - Calls external CoinGecko API via Chainlink Functions.
    - Automatically manages subscriptions using Foundry.
    - Stores and exposes real-time crypto data on-chain.

---

### 6️⃣ CCIP (Cross-Chain Interoperability Protocol)

**Description:**  
CCIP enables secure cross-chain messaging and token transfers, facilitating interoperability between blockchains.

**Example Project:**  
- **FlexiToken Cross-Chain Bridge**
  - **Description:**  
    Demonstrates a complete cross-chain token bridging system using **Chainlink CCIP**.
  - **Components:**
    - `FlexiToken` — A custom mintable/burnable ERC20 token.
    - `FlexiTokenPool` — A CCIP-compatible token pool that handles secure bridging logic.
    - `Vault` — Auxiliary contract for managing minting and burning during cross-chain operations.
  - **Features:**  
    - Allows users to bridge tokens across chains securely.
    - Implements mint/burn flows to maintain supply integrity.
    - Includes full deployment, configuration, and CCIP setup scripts.


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