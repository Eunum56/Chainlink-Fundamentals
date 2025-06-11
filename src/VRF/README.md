# 🎲 Chainlink VRF Random Number Generator

This project is a Solidity smart contract that demonstrates how to integrate **Chainlink VRF (Verifiable Random Function)** to securely generate random numbers on-chain. It’s perfect for use cases like gaming, NFT minting, or any decentralized application that requires **provably fair randomness**.

---

## 🚀 Overview

This contract uses:
- **Solidity (v0.8.26)**
- **Chainlink VRF v2 Plus** (Subscription Manager)
- **Foundry** for deployment and scripting

It allows users to request random numbers and stores the result securely, which can be retrieved later.

---

## 🛠️ Features

- Request random numbers securely
- Handles asynchronous callbacks using `fulfillRandomWords()`
- Stores random numbers per user
- Supports multiple chains through a helper configuration
- Emits events for both requests and fulfillments

---

## 🔑 How It Works

- **requestRandomNumber()**  
  Called by users to request a random number from Chainlink VRF. Emits `RandomNumberRequested(address user)` event.

- **fulfillRandomWords()**  
  Called by the Chainlink VRF Coordinator to deliver randomness. Stores the random number in a mapping keyed by the user's address. Emits `RandomNumberFullFilled(address user, uint256 randomNumber)` event.

- **getMyRandomNumber()**  
  Allows users to retrieve their stored random number.

---

## 🌐 Supported Networks

- Ethereum Sepolia
- Arbitrum Sepolia
- Ethereum Mainnet  
(Additional chains can be added in the helper configuration.)

---

## 🚀 Deployment

- Contract deployed and verified on Ethereum Sepolia at:  
  `0xB4Fdf8339d6Ed1B76D2d485573EEdc0Dc5Ecb3d2`  
  Ready to use and test on the network.

- To deploy on other chains, update the helper configuration with the appropriate VRF Coordinator address, key hash, and subscription ID.

---

## 📑 Prerequisites

- Foundry installed
- A funded wallet with testnet or mainnet tokens
- Chainlink VRF subscription set up

---

## 🔗 Resources

- [Chainlink VRF v2 Plus Documentation](https://docs.chain.link/vrf/v2/introduction/)
- [Cyfrin Updraft Course](https://updraft.cyfrin.io/courses/chainlink-fundamentals/)
- [Chainlink Subscription Manager](https://vrf.chain.link/)

---
