# Astria web3

This repository contains smart contracts and front end interfaces for the Astria Shared Sequencer.

### Rough-draft how to

* Dependencies
    * dotenv - https://crates.io/crates/dotenv
    * Foundry + Forge - https://book.getfoundry.sh/getting-started/installation

```bash
# install dependencies
npm install -g dotenv-cli
curl -L https://foundry.paradigm.xyz | bash

# deploy weth9
cd packages/weth9
cp .env.example .env
dotenv -- bash -c 'RUST_LOG=debug forge create \
  --private-key $PRIVATE_KEY \
  --rpc-url $JSON_RPC \
  src/Weth9.sol:WETH9'
```
