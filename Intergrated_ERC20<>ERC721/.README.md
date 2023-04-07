# Intergrated ERC20 <> ERC721

## Description

An ERC 20 token representing an asset is connected to a ERC721 contract. The 721 token represents an off-chain clause such as terms and conditions - which can be a PDF document stored on a private IPFS instance, run by the ERC 20 token issuer.

ERC20 token issuer have the ability to initiate updates to the bound documentation (ERC721) of their ERC20 token. However, before these updates can be implemented, multi-sig (or equivalent) sign-off is required from the ERC 20 token holders. This ensures that the updates are valid and approved by all relevant parties before being incorporated into the contract.

For ERC 20 token holder who declines the change in terms and conditions, their token changes state and can only move from their wallet to issuers wallet.

## How to use

To update the bound documentation (ERC721), the token issuer can call `proposeUpdateClause` to initiate update of the ERC721 of the ERC20 token or call `proposeUpdateClauseNFTbaseURI` to initiate update of the metadata linked to ERC721. After 100% (can be config) of ERC 20 token holders sign-off (voted on update proposal), the token issuer can call `execute` to execute the proposed update.

## Installation

1. Clone this repository
2. Run command: `yarn` to install dependencies
3. Use .env.example to create and fill out .env file

## Commands

Compile Smart Contracts
```shell
npx hardhat compile
```

For local testing use the flag ```--network localhost``` with each command

```shell
npx hardhat deploy
npm hardhat node
npx hardhat run scripts/deploy.js
```

For goerli / sepolia testnet, put INFURA_ID in .ENV

```shell
npx hardhat --network [goerli / sepolia] run scripts/deploy.js
```