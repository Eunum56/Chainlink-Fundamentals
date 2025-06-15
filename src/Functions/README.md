# 🔗 TopCryptoDetails (Chainlink Functions x Foundry)

**TopCryptoDetails** is a smart contract that uses **Chainlink Functions** to fetch live crypto data from the CoinGecko API — built and deployed entirely using **Foundry**, without any frontend or manual Chainlink UI interaction.

---

## 🧠 Overview

This project demonstrates how to:

* ✅ **Programmatically** create and manage Chainlink Functions subscriptions
* ✅ Fund the subscription with LINK tokens
* ✅ Add consumer contracts to the subscription
* ✅ Request external data from CoinGecko and handle responses on-chain

All of this is done **entirely using Foundry scripts** — **no manual setup** on Chainlink’s UI or dashboard is required.

---

## 🔌 What the Contract Does

* The `TopCryptoDetails` contract requests the **top N cryptocurrencies** by market cap from CoinGecko.
* Chainlink Functions handles the off-chain API call and returns the response on-chain.
* The result is stored in the smart contract and can be read anytime.

---

## 📦 Contracts & Scripts

### 🧱 Main Contract

* `TopCryptoDetails.sol` – The smart contract that sends Chainlink Function requests and stores responses.

### ⚙️ Supporting Scripts

1. `TCDHelperConfig.s.sol`
   Contains network-specific configuration (router address, LINK token, DON ID).

2. `DeployTopCryptoDetails.s.sol`
   Main deployment script. Handles:

   * Subscription creation
   * Subscription funding
   * Contract deployment
   * Adding the contract as a consumer

3. `TCDInteractions.s.sol`
   Contains modular logic:

   * `CreateSubscription`
   * `FundSubscription`
   * `AddConsumer`

---

## 🌍 Deployed Contracts

| Network          | Address                                      |
| ---------------- | -------------------------------------------- |
| Ethereum Sepolia | `0x511fFAC1d658C8498b26Ec7D889cBf4260C8F55B` |
| Arbitrum Sepolia | `0xeB79B5c31652D376D9d054b74450257f7CAC1D1a` |

> Both contracts are verified and successfully fulfilled Chainlink Functions requests.

---

## ⚡ Fully Programmatic Workflow

From start to finish:

* 🚫 No Chainlink UI
* 🚫 No manual dashboard steps
* ✅ Everything is scripted using Foundry:

  * Subscription creation
  * Funding with LINK
  * Contract deployment
  * Adding consumer

---

## 🔀 Flow Summary

1. **Create Subscription**
   `CreateSubscription` script interacts with the router to initialize a new Functions subscription.

2. **Fund Subscription**
   `FundSubscription` sends 5 LINK to the subscription using `IERC677.transferAndCall`.

3. **Deploy TopCryptoDetails Contract**
   `DeployTopCryptoDetails` deploys the main contract with router, subId, and DON ID.

4. **Add Consumer**
   `AddConsumer` adds the deployed contract to the subscription for authorization.

5. **Request Top Crypto**
   Call `sendRequest()` on `TopCryptoDetails` to fetch top coins from CoinGecko.
   The Chainlink DON processes the request and fulfills it on-chain.

---

## ✅ Status

* Created subscription ✅
* Funded with 5 LINK ✅
* Contract deployed ✅
* Consumer added ✅
* Request sent & fulfilled ✅
* Data stored on-chain ✅