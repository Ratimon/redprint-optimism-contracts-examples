// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {console} from "@forge-std/console.sol";

import {Test} from "@forge-std/Test.sol";

import {SafeProxy} from "@safe-contracts/proxies/SafeProxy.sol";
import {AddressManager} from "@main/legacy/AddressManager.sol";
import {ProxyAdmin} from "@main/universal/ProxyAdmin.sol";

import {Proxy} from "@main/universal/Proxy.sol";
import {SimpleStorage} from "./Proxy.t.sol";
import {L1ChugSplashProxy} from "@main/legacy/L1ChugSplashProxy.sol";
import {ResolvedDelegateProxy} from "@main/legacy/ResolvedDelegateProxy.sol";

import {IDeployer, getDeployer} from "@script/deployer/DeployScript.sol";

import {DeployAllScript} from "@script/000_DeployAll.s.sol";


contract ProxyAdmin_Test is Test {
    string mnemonic = vm.envString("MNEMONIC");
    uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    address owner = vm.envOr("DEPLOYER", vm.addr(ownerPrivateKey));

    IDeployer deployerProcedue;

    SafeProxy safeProxy;
    AddressManager addressManager;
    ProxyAdmin admin;

    Proxy proxy;
    SimpleStorage implementation;
    L1ChugSplashProxy chugsplash;
    ResolvedDelegateProxy resolved;

    function setUp() external {
        deployerProcedue = getDeployer();
        deployerProcedue.setAutoBroadcast(false);

        DeployAllScript allDeployments = new DeployAllScript();
        allDeployments.run();

        deployerProcedue.deactivatePrank();

    }


    function test_mock_succeeds() external {
        assertEq(true, true);
    }

}
