// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { VmSafe } from "@forge-std/Vm.sol";
import { Script } from "@forge-std/Script.sol";

import { console2 as console } from "@forge-std/console2.sol";
import { stdJson } from "@forge-std/StdJson.sol";

import { Safe } from "@safe-contracts/Safe.sol";
import { SafeProxyFactory } from "@safe-contracts/proxies/SafeProxyFactory.sol";
import { Enum as SafeOps } from "@safe-contracts/common/Enum.sol";