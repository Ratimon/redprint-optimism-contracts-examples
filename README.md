# Optimism Contracts

## Quick Start

These following commands will save deployment artifacts at [`deployments/<chain-id>/`](./deployments/.deploy)

```bash
pnpm deploy deploy_0_safe
```

## Quick Installation

### zellij

[zellij](https://zellij.dev/) is a useful multiplexer (think tmux) for which we have included a [layout file](./zellij.kdl) to get started

Once installed simply run:

```bash
nvm use 18.17.0
forge init optimism-contracts-foundry
```

```bash
cd optimism-contracts-foundry
pnpm init
```
