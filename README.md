<h1>📚 OPStack Contracts 's Deployment Pipline using Redprint` 's POC 📚</h1>

A PoC showing how `Redprint` works. This developer toolkit includes both interactive code generator and template to modify & deploy **OPstack** ’s smart contract components in modular style. It also acts an educational place to study OPStack component at smart contract level.

> **Note**💡

> The code is not audited yet. Please use it carefully in production.

- [What is it for](#what-is-it-for)
- [How It Works](#how-it-works)
- [Installation](#installation)
- [Quickstart](#quickstart)
- [Contributing](#contributing)
- [Architecture](#architecture)

## What is it for ?

This **OP-Stack-oriented App-chain** building block is intended to better introduce and onboard blockchain builder into Optimism 's [Superchain](https://docs.optimism.io/stack/explainer) Ecosystem.

> **Note**💡

**The OP Stack can be thought of as software components that either help define a specific layer of the Optimism ecosystem or fill a role as a module within an existing layer.**

![modular stack](./assets/modular_stack.png)

You can check out details in different layers here : [Reference](https://docs.optimism.io/stack/components).

While developer experience and security are our top priorities, we aim to provide the developer-focused educational tool, such that the new experimental **layer2** or **App-chain** can be quicky bootstapped in **superchain** community & ecosystem. This align with **Ethereum** 's Rollup-centric Roadmap.

## How It Works

`Redprint` consists of:

1. `Redprint Wizard` (**Web UI**)

We are building `Redprint Wizard`, a web application to interactively customize, mix & match, d`eploy layer2 **OPStack** chain / **App-chain**.

It can be as educational platform to explore and select different versions of smart contract components for different usecases / features. Then, the `Redprint` will generate all required solidity code, including both smart contract parts and their relevant deploy scripts.

By way of illustration, this is a **low-fidelity wireframe** showing how it works:

![ui demo](./assets/demo.png)

It can be seen above that the developers have several options to choose their own desired layers. In our example above, it is the **governance** Layer and the [`Safe's Multi-sig`](https://github.com/safe-global/safe-smart-account) is picked over other Governor-style contract systems.

To be more specific, another option is **Compound-style contract**. Different sets of parameters can be selected based on the preference. This includes **Voting Delay**, **Voting Period**, **Time Lock Period** and etc.

This is just one example. There are many other interesting customizable contracts to explore and add hackable features. For instance, customized bridge can be created by extending `IStandardard Bridge` as well as modifying `L1StandardBridge` or `L1ERC721Bridge`.

2. `redprint-forge` (**Framework**)

We are developing `redprint-forge`, a modular solidity-based framework to deploy OP stack smart contract. It works as an engine to:

- Provide type-safe deployment functions for **OPStack**'s smart contract component. This ensures correct type and order of arguments, enhancing security in smart contract development
- Save deployment schemas in **json** file
- Separate into each of modular and customizable components

The directories below show how modular the `redprint-forge` 's **deployment system** is :

On the one hand, the first one is the deployment script written in [/script](./script), using `redprint-forge` libirary and style guide:

```sh
├── script
│   ├── 000_DeployAll.s.sol
│   ├── 100_DeploySafe.s.sol
│   ├── 200_SetupSuperchain.s.sol
│   ├── 201_DeployAddressManager.s.sol
│   ├── 202_DeployPloxyAdmin.s.sol
```

I highlight that the developer is able to aggregate all script into single one like in [/script](./script/000_DeployAll.s.sol):

```ts

/** ... */

// `redprint-forge` 's core engine
import {IDeployer, getDeployer} from "@script/deployer/DeployScript.sol";

/** ... */

// application-specific logic
import {DeploySafeScript} from "@script/100_DeploySafe.s.sol";
import {SetupSuperchainScript} from "@script/200_SetupSuperchain.s.sol";

contract DeployAllScript is Script {

    /** ... */

    function run() public {

        // a singleton global deployer that any deployment script can access
        deployerProcedue = getDeployer();
        // auto saving address schema in .json file
        deployerProcedue.setAutoSave(true);

        DeploySafeScript safeDeployments = new DeploySafeScript();
        SetupSuperchainScript superchainSetups = new SetupSuperchainScript();

        //1) set up Safe Multisig
        safeDeployments.deploy();
        //2) set up superChain
        superchainSetups.run();
        //3) TODO set up plasma
        //4) TODO set up layer2 OP Chain

    }
    /** ... */

}
```

> **Note**💡

The first digit represents the higher level of deployment logic, compared to the last degits. For example, `setup_200_superchain` whose number is `200` includes all of scripts whose numbers starting with `2XX` (e.g. `201` or `deploy_201_address_manager`).

> **Note**💡

You can also checkout how our MVP of deployer library works behind the scene here [Deployer.sol](https://github.com/Ratimon/redprint-optimism-contracts-examples/blob/efa1d92424989f0b7c313f9a1d1592b64ea1aadd/script/deployer/Deployer.sol)

On the otherhand, the second one is the original script from **Optimism**'s [`Deploy.s.sol`](https://github.com/ethereum-optimism/optimism/blob/abfc1e1f37a89405bacd08a3bb6363250d3f68f5/packages/contracts-bedrock/scripts/Deploy.s.sol).

```sh
├── script
│   ├──
│   ├── Deploy.s.sol
│   ├──
```

As you can see, the original deployment script is a single file, containing more than 1000 lines of code for all deployment logics for all contracts. Meanwhile, `redprint-forge` abstracts and separates them into modular components, enabling better readabillity for smart contract developer.

Using together with `Redprint Wizard`, the generated solidity code which includes both smart contract parts and their relevant deploy scripts are displayed in customizable way, leading to better developer experience and creativity.

Furthermore, these deployment components are extremely re-usable to replicate the same environment when testing. This will speed up the development process, as the developer does not need to write deployment logics again in test suites.

As you can see in [ProxyAdmin.t.sol](./test/ProxyAdmin.t.sol), we can use those deployment components as a test harness.

```sh
├── test
│   ├──
│   ├── ProxyAdmin.t.sol
│   ├──
```

This could, together with **Type-Safe Deployment** feature, also improve overall security, because it potentially minimize false positives from using different deployment logics among production and test environments.

## Installation

[zellij](https://zellij.dev/) is a useful multiplexer (think tmux) for which we have included a [layout file](./zellij.kdl) to get started

Once installed, simply run:

```bash
nvm use 18.17.0
```

```bash
pnpm i
```

## Quickstart

1. Copy [`.env`](./.env) into `.env.<network>.local` and modify as required. For example, this is a file (`.env.optimism.local`)(https://github.com/Ratimon/optimism-contracts-foundry/.env.optimism.local) for optimism network:

> **Note**💡

More style and convention guide for environment variable management can be found here : [ldenv](https://github.com/wighawag/ldenv)

```sh
# -------------------------------------------------------------------------------------------------
# IMPORTANT!
# -------------------------------------------------------------------------------------------------
# USE .env.local and .env.<context>.local to set secrets
# .env and .env.<context> are used for default public env
# -------------------------------------------------------------------------------------------------

RPC_URL_localhost=http://localhost:8545

#secret management
MNEMONIC="test test test test test test test test test test test junk"
DEPLOYER=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
# local network 's default private key so it is still not exposed
DEPLOYER_PRIVATE_KEY=ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
ENV_MODE=DEPLOYMENT_CONTEXT

# script/Config.sol
DEPLOYMENT_OUTFILE=deployments/31337/.save.json
DEPLOY_CONFIG_PATH=
CHAIN_ID=
CONTRACT_ADDRESSES_PATH=deployments/31337/.save.json
DEPLOYMENT_CONTEXT=localhost
IMPL_SALT=
STATE_DUMP_PATH=
SIG=
DEPLOY_FILE=
DRIPPIE_OWNER_PRIVATE_KEY=9000

# deploy-Config
GS_ADMIN_ADDRESS=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
GS_BATCHER_ADDRESS=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
GS_PROPOSER_ADDRESS=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
GS_SEQUENCER_ADDRESS=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
L1_RPC_URL=http://localhost:8545
```

> **Note**💡

`deployments/31337/.deploy` is case sensitive.

2. Run multi-windows terminal:

```sh
pnpm start
```

3. Run solidity deploymemt scripts:

These following commands will save deployment artifacts at [`deployments/<chain-id>/`](./deployments/.save.json)

There are two ways:

- Deploy each of individual components:

```bash
pnpm deploy_100_safe
```

```bash
pnpm deploy_201_address_manager
```

```bash
pnpm deploy_202_proxy_admin
```

- Alternatively, Deploy each set of contracts :

```bash
pnpm setup_200_superchain
```

or deploy all of them in single script:

```bash
pnpm deploy_000_all
```

4. Test your contracts

```bash
pnpm test
```

## Contributing

WIP

## Architecture

WIP
