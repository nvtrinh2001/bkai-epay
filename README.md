# Decentralised Payment Channel

This project is my attempt to create a decentralised payment channel, using Solidity and Hardhat.

## How it works

`**EPay.sol**`
Sender A can send ETH to the smart contract, and can withdraw it back to their wallet.
Sender A can allow recipient B to withdraw a specific amount of ETH, which has been sent to the smart contract by A.
Recipient B then can withdraw ETH, as long as this amount is less than or equal to the allowance.

`**UpdatedEPay.sol**`
Sender A can send ETH to the smart contract, and can withdraw it back to their wallet.
Sender A can allow recipient B to withdraw a specific amount of ETH, which has been sent to the smart contract by A.
Sender A only allows recipient B to withdraw within a specific amount of time.
Sender B has to withdraw all the allowance in one go.
Both A and B have to interact with the smart contract by scripts.

## Quick Start

**1. Clone this directory and install dependencies**

```
git clone git@github.com:nvtrinh2001/bkai-epay.git
cd bkai-epay
yarn
```

**2. Deploy**

- Deploy on Hardhat network:

```
yarn hardhat deploy
```

- Deploy on Rinkeby testnet: update all the variables in the `.env` file and run:

```
yarn hardhat deploy --network rinkeby
```

**3. Interact with the contract**

- You can use files in `scripts` folder to interact with the smart contract by running:

```
yarn hardhat run scripts/SCRIPT_FILE_NAME_HERE --network localhost/rinkeby
```
