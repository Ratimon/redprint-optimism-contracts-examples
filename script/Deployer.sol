// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "@forge-std/Script.sol";
import { stdJson } from "@forge-std/StdJson.sol";
import { console2 as console } from "@forge-std/console2.sol";
import { Executables } from "@script/Executables.sol";
import { EIP1967Helper } from "test/mocks/EIP1967Helper.sol";
import { IAddressManager } from "@script/interfaces/IAddressManager.sol";
import { LibString } from "@solady/utils/LibString.sol";
import { Artifacts, Deployment } from "@script/Artifacts.s.sol";
import { Config } from "@script/Config.sol";