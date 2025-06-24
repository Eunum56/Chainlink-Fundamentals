# 🔗 Chainlink Data Streams Project

This project showcases a practical integration of **Chainlink Data Streams** through **Log Triggered Automation**. It uses smart contracts to emit specific logs and trigger Chainlink Automation to fetch low-latency on-chain price data.

## 📘 Overview

- **LogEmitter** emits a `Log(address indexed)` event, acting as a trigger for Chainlink nodes.
- **StreamsUpkeep** listens for that log, verifies the request using the `StreamsLookup` mechanism, and calls `performUpkeep` to store the latest ETH/USD price.

The idea is to simulate how on-chain systems can respond to real-world events by emitting logs, verifying data, and storing it securely on-chain — using Chainlink's powerful data and automation infrastructure.

## ⚙️ How It Works

1. A log is emitted from the `LogEmitter` contract.
2. Chainlink Automation nodes pick up this log.
3. The `checkLog` and `performUpkeep` lifecycle kicks in through the `StreamsUpkeep` contract.
4. The verified low-latency price data is fetched from the Chainlink Data Streams Aggregation Network and processed on-chain.

## 🌐 Networks

Tested on:
- OP Sepolia:
- **Log Emitter** `0x89491AaF01b3Bc92FACc1ec1174a9a8e50cFa720`
- **StreamsUpkeep** `0x17952596453663D0c8DC853128537e6dc62Ba553`

## 🚀 Purpose

This project is part of my learning journey through the **Chainlink Fundamentals Course by Cyfrin Updraft**. It demonstrates:
- Programmatic automation registration
- Log-based triggers
- Integration with Data Streams
- Foundry-based scripting and deployment

## 🙏 Acknowledgements

Big thanks to:
- [Chainlink Labs](https://chain.link/)
- [Patrick Collins](https://twitter.com/PatrickAlphaC)
- [Cyfrin Updraft](https://updraft.cyfrin.io)

Your content is making learning in Web3 smoother and much more empowering for beginners like me.

