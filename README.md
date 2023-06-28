# Astria web3

This repository contains smart contracts and front end interfaces for the Astria Shared Sequencer.

### Rough-draft how to

* Dependencies
    * dotenv - https://crates.io/crates/dotenv
    * Foundry + Forge - https://book.getfoundry.sh/getting-started/installation

```bash
# clone repo while also cloning submodules
git clone --recurse-submodules git@github.com:astriaorg/astria-web3.git

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

# deploy uniswap v3
cd packages/uniswapv3
# NOTE - must get Weth9 address from previous step
cp .env.example .env
# install base64 contract
npm install
dotenv -- bash -c 'RUST_LOG=debug forge script script/DeployUniswapV3.s.sol:DeployUniswapV3 \
  --optimizer-runs 2 \
  --private-key $PRIVATE_KEY \
  --rpc-url $JSON_RPC \
  --chain-id 912559 \
  --slow \
  --broadcast --skip-simulation -vvvvv'
```
