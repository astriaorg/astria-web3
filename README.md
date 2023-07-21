# Astria web3

This repository contains smart contracts and front end interfaces for the Astria Shared Sequencer.

Make sure you have the following installed:

  * npm
  * dotenv - `npm install -g dotenv-cli`
  * [Foundry + Forge](https://book.getfoundry.sh/getting-started/installation)

Then, clone the repo using the `--recurse-submodules` flag to bring in all the submodules.
```bash
git clone --recurse-submodules git@github.com:astriaorg/astria-web3.git
cd astria-web3
```

### Install dependencies

```bash
npm install -g dotenv-cli
curl -L https://foundry.paradigm.xyz | bash
```

For local dev, make sure the [Astria Dev Cluster](https://github.com/astriaorg/dev-cluster) is running.
Then deploy contracts in the following order:

### weth9
```bash
cd packages/weth9
cp .env.example .env
dotenv -- bash -c 'RUST_LOG=debug forge create \
  --private-key $PRIVATE_KEY \
  --rpc-url $JSON_RPC \
  src/Weth9.sol:WETH9'
```

Upon completion, the following output will be shown (the addresses will be different):

```bash
Deployer: 0xaC21B97d35Bf75A7dAb15f35b121a50e78A72F30
Deployed to: 0xA53639fB5458e65E4fA917FF951C390292C24A15
Transaction hash: 0x775c63649c25d7b8029e2e786e001fcda1618723a305c2e384d5cae453a32ad7
```

Copy the `Deployed to:` address to use for deploying Uniswap.

### Uniswap V3

Before deploying Uniswap, make sure that you have ran the `weth9` steps above.

```bash
cd packages/uniswapv3
cp .env.example .env
```

Open the `.env` file and replace the `WETH9_ADDRESS=` with the address from the `weth9` "Deployed to:" output.
Install the `base64` contract.

```bash
npm install
dotenv -- bash -c 'RUST_LOG=debug forge script script/DeployUniswapV3.s.sol:DeployUniswapV3 \
  --optimizer-runs 2 \
  --private-key $PRIVATE_KEY \
  --rpc-url $JSON_RPC \
  --chain-id 912559 \
  --slow \
  --broadcast --skip-simulation -vvvvv'
```
### Generate Transactions

By default, the `just generate-transactions` command will pull environment variables from the .env file. If you have deployed your own rollup in the [dev cluster](https://github.com/astriaorg/dev-cluster), you should replace the arguments in the `just` command with the rollup name and chain id you used for that deployment. 

```bash
cd packages/evm-test-data
cp .env.example .env
just generate-transactions <optional-rollupName> <optional-chainId> <optional-priavteKey>
```



### Running Forge Tests

```bash
cd packages/package-you-want-to-test
forge test --rpc-url http://executor.astria.localdev.me
```
