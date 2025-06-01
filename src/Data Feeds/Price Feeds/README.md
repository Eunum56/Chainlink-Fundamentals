# 🎮 Dynamic Game Token Minting with Chainlink Price Feeds

This project implements a dynamic ERC20 token minting system for a gaming ecosystem using **Chainlink Price Feeds** to determine the correct token mint amount in USD equivalent.

---

## ✨ Features

- **Dynamic Token Minting**: Users send ETH to the GameEngine contract, which calculates the USD value using Chainlink Price Feeds, and mints the appropriate number of tokens (1 USD = 10 tokens).
- **Secure Ownership Control**: Only the GameEngine contract can mint or burn tokens, ensuring game logic integrity.
- **Chainlink Price Feed Integration**: Uses Chainlink’s reliable ETH/USD price feed for accurate real-world conversion.

---

## 📦 Contracts

- **GameToken**: ERC20 token with `mint()` and `burn()` functions restricted to the GameEngine contract.
- **GameEngine**: Accepts ETH payments, fetches ETH/USD price, and mints tokens to users based on the USD value of ETH sent.

---

## ✅ Test Coverage

Below is the **Foundry test coverage report** for the project. It shows that **GameEngine** and **GameToken** contracts have achieved 100% coverage across all metrics:

| Contract                                     | Statements | Branches | Functions | Lines |
|----------------------------------------------|------------|----------|-----------|-------|
| src/Data Feeds/Price Feeds/GameEngine.sol    | 100% (37/37) | 100% (43/43) | 100% (9/9) | 100% (9/9) |
| src/Data Feeds/Price Feeds/GameToken.sol     | 100% (9/9) | 100% (7/7) | 100% (2/2) | 100% (4/4) |

**unit tests** and **integration tests** to ensure robust security.




---

## 🔗 Deployment

- **Network**: Ethereum Sepolia
- **GameToken Contract**: `0xb44024D10e3502E29BF622fd8Ee0e9b96C7BE141`
- **GameEngine Contract**: `0x52c2B0a6b10280c78CBb1cbf38E5479F701498A5`

---

## 🛠️ How It Works

1. User sends ETH to the GameEngine contract.
2. GameEngine fetches the ETH/USD price from Chainlink’s Price Feed.
3. Converts ETH amount into USD value.
4. Calculates how many tokens to mint (1 USD = 10 tokens).
5. Mints tokens to the user’s address.

---

## 🤝 Acknowledgements

- Chainlink Price Feeds
- Cyfrin Updraft Chainlink Fundamentals course
- OpenZeppelin Contracts

---

## 📄 License

MIT
