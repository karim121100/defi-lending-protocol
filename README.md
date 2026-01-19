# DeFi Lending Protocol

![Solidity](https://img.shields.io/badge/solidity-^0.8.20-blue)
![DeFi](https://img.shields.io/badge/category-lending-purple)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

**DeFi Lending Protocol** allows trustless peer-to-pool lending. Suppliers provide liquidity to the pool to earn passive interest, while borrowers can take out over-collateralized loans.

## Mechanics

* **Collateral**: Users deposit ETH.
* **Borrowing**: Users borrow USDC up to 80% (LTV) of their ETH value.
* **Interest**: Borrowers pay interest, which accumulates in the pool for suppliers.
* **Liquidation**: If ETH price drops and Health Factor < 1, liquidators can seize collateral at a discount to repay the debt.

## Usage

```bash
# 1. Install
npm install

# 2. Deploy Protocol & Mock Tokens
npx hardhat run deploy.js --network localhost

# 3. Supply Collateral (ETH)
node supply_collateral.js

# 4. Borrow Stablecoin (USDC)
node borrow_asset.js

# 5. Repay Loan
node repay_loan.js
