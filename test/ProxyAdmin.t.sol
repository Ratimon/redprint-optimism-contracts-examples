// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {console} from "@redprint-forge-std/console.sol";

import {Test} from "@redprint-forge-std/Test.sol";

import {GnosisSafeProxy as SafeProxy} from "@redprint-safe-contracts/proxies/GnosisSafeProxy.sol";
import {IAddressManager} from "@redprint-core/legacy/interfaces/IAddressManager.sol";
import {AddressManager} from "@redprint-core/legacy/AddressManager.sol";
import {ProxyAdmin} from "@redprint-core/universal/ProxyAdmin.sol";

import {Proxy} from "@redprint-core/universal/Proxy.sol";
import {SimpleStorage} from "./Proxy.t.sol";
import {L1ChugSplashProxy} from "@redprint-core/legacy/L1ChugSplashProxy.sol";
import {ResolvedDelegateProxy} from "@redprint-core/legacy/ResolvedDelegateProxy.sol";

import {IDeployer, getDeployer} from "@scripts/deployer/DeployScript.sol";

import {DeploySafeProxyScript} from "@scripts/101_DeploySafeProxyScript.s.sol";
import {DeployAddressManagerScript} from "@scripts/201A_DeployAddressManagerScript.s.sol";
import {DeployAndSetupProxyAdminScript} from "@scripts/201B_DeployAndSetupProxyAdminScript.s.sol";

contract ProxyAdmin_Test is Test {
    string mnemonic = vm.envString("MNEMONIC");
    uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    address owner = vm.envOr("DEPLOYER_ADDRESS", vm.addr(ownerPrivateKey));

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

        DeploySafeProxyScript safeDeployments = new DeploySafeProxyScript();
        DeployAddressManagerScript addressManagerDeployments = new DeployAddressManagerScript();
        DeployAndSetupProxyAdminScript proxyAdminDeployments = new DeployAndSetupProxyAdminScript();
        deployerProcedue.activatePrank(vm.envAddress("DEPLOYER_ADDRESS"));

        // Deploy Multisig
        (,, safeProxy)= safeDeployments.deploy();
        // Deploy the legacy AddressManager
        addressManager = addressManagerDeployments.deploy();
        // Deploy the proxy admin
        admin = proxyAdminDeployments.deploy();

        deployerProcedue.deactivatePrank();
        // initialize
        proxyAdminDeployments.initialize();
        deployerProcedue.activatePrank(vm.envAddress("DEPLOYER_ADDRESS"));
        
        // Deploy the standard proxy
        proxy = new Proxy(address(admin));
        // Deploy the legacy L1ChugSplashProxy with the admin as the owner
        chugsplash = new L1ChugSplashProxy(address(admin));

        deployerProcedue.deactivatePrank();


    }

    modifier beforeEach() {
        vm.startPrank(owner);

        // The proxy admin must be the new owner of the address manager
        addressManager.transferOwnership(address(admin));
        // Deploy a legacy ResolvedDelegateProxy with the name `a`.
        // Whatever `a` is set to in AddressManager will be the address
        // that is used for the implementation.
        resolved = new ResolvedDelegateProxy(addressManager, "a");

        // Set the address of the address manager in the admin so that it
        // can resolve the implementation address of legacy
        // ResolvedDelegateProxy based proxies.

        vm.stopPrank();
        vm.startPrank(address(safeProxy));

        // Set the reverse lookup of the ResolvedDelegateProxy
        // proxy
        admin.setImplementationName(address(resolved), "a");

        // // Set the proxy types
        admin.setProxyType(address(proxy), ProxyAdmin.ProxyType.ERC1967);
        admin.setProxyType(address(chugsplash), ProxyAdmin.ProxyType.CHUGSPLASH);
        admin.setProxyType(address(resolved), ProxyAdmin.ProxyType.RESOLVED);
        vm.stopPrank();

        implementation = new SimpleStorage();
        _;
    }

    function test_setImplementationName_succeeds() external beforeEach {
        // deployer.activatePrank(vm.envAddress("DEPLOYER_ADDRESS"));
        vm.prank(address(safeProxy));
        admin.setImplementationName(address(1), "foo");
        assertEq(admin.implementationName(address(1)), "foo");
    }

    function test_setAddressManager_notOwner_reverts() external beforeEach {
        vm.startPrank(address(0));
        vm.expectRevert("Ownable: caller is not the owner");
        admin.setAddressManager(IAddressManager((address(0))));
        vm.stopPrank();
    }

    function test_setImplementationName_notOwner_reverts() external beforeEach {
        vm.startPrank(address(0));
        vm.expectRevert("Ownable: caller is not the owner");
        admin.setImplementationName(address(0), "foo");
        vm.stopPrank();
    }

    function test_setProxyType_notOwner_reverts() external beforeEach {
        vm.prank(address(0));
        vm.expectRevert("Ownable: caller is not the owner");
        admin.setProxyType(address(0), ProxyAdmin.ProxyType.CHUGSPLASH);
    }

    function test_owner_succeeds() external beforeEach {
        assertEq(admin.owner(), address(safeProxy));
    }

    function test_proxyType_succeeds() external beforeEach {
        assertEq(uint256(admin.proxyType(address(proxy))), uint256(ProxyAdmin.ProxyType.ERC1967));
        assertEq(uint256(admin.proxyType(address(chugsplash))), uint256(ProxyAdmin.ProxyType.CHUGSPLASH));
        assertEq(uint256(admin.proxyType(address(resolved))), uint256(ProxyAdmin.ProxyType.RESOLVED));
    }

    function test_erc1967GetProxyImplementation_succeeds() external beforeEach {
        getProxyImplementation(payable(proxy));
    }

    function test_chugsplashGetProxyImplementation_succeeds() external beforeEach {
        getProxyImplementation(payable(chugsplash));
    }

    function test_delegateResolvedGetProxyImplementation_succeeds() external beforeEach {
        getProxyImplementation(payable(resolved));
    }

    function getProxyImplementation(address payable _proxy) internal {
        {
            address impl = admin.getProxyImplementation(_proxy);
            assertEq(impl, address(0));
        }
        vm.prank(address(safeProxy));
        admin.upgrade(_proxy, address(implementation));

        {
            address impl = admin.getProxyImplementation(_proxy);
            assertEq(impl, address(implementation));
        }
    }

    function test_erc1967GetProxyAdmin_succeeds() external beforeEach {
        getProxyAdmin(payable(proxy));
    }

    function test_chugsplashGetProxyAdmin_succeeds() external beforeEach {
        getProxyAdmin(payable(chugsplash));
    }

    function test_delegateResolvedGetProxyAdmin_succeeds() external beforeEach {
        getProxyAdmin(payable(resolved));
    }

    function getProxyAdmin(address payable _proxy) internal view {
        address proxyAdminOwner = admin.getProxyAdmin(_proxy);
        assertEq(proxyAdminOwner, address(admin));
    }

    function test_erc1967ChangeProxyAdmin_succeeds() external beforeEach {
        changeProxyAdmin(payable(proxy));
    }

    function test_chugsplashChangeProxyAdmin_succeeds() external beforeEach {
        changeProxyAdmin(payable(chugsplash));
    }

    function test_delegateResolvedChangeProxyAdmin_succeeds() external beforeEach {
        changeProxyAdmin(payable(resolved));
    }

    function changeProxyAdmin(address payable _proxy) internal {
        ProxyAdmin.ProxyType proxyType = admin.proxyType(address(_proxy));

        vm.prank(address(safeProxy));
        admin.changeProxyAdmin(_proxy, address(128));

        // The proxy is no longer the admin and can
        // no longer call the proxy interface except for
        // the ResolvedDelegate type on which anybody can
        // call the admin interface.
        if (proxyType == ProxyAdmin.ProxyType.ERC1967) {
            vm.expectRevert("Proxy: implementation not initialized");
            admin.getProxyAdmin(_proxy);
        } else if (proxyType == ProxyAdmin.ProxyType.CHUGSPLASH) {
            vm.expectRevert("L1ChugSplashProxy: implementation is not set yet");
            admin.getProxyAdmin(_proxy);
        } else if (proxyType == ProxyAdmin.ProxyType.RESOLVED) {
            // Just an empty block to show that all cases are covered
        } else {
            vm.expectRevert("ProxyAdmin: unknown proxy type");
        }

        // Call the proxy contract directly to get the admin.
        // Different proxy types have different interfaces.
        vm.prank(address(128));
        // vm.changePrank(address(128));
        if (proxyType == ProxyAdmin.ProxyType.ERC1967) {
            assertEq(Proxy(payable(_proxy)).admin(), address(128));
        } else if (proxyType == ProxyAdmin.ProxyType.CHUGSPLASH) {
            assertEq(L1ChugSplashProxy(payable(_proxy)).getOwner(), address(128));
        } else if (proxyType == ProxyAdmin.ProxyType.RESOLVED) {
            assertEq(addressManager.owner(), address(128));
        } else {
            assert(false);
        }
    }

    function test_erc1967Upgrade_succeeds() external beforeEach {
        upgrade(payable(proxy));
    }

    function test_chugsplashUpgrade_succeeds() external beforeEach {
        upgrade(payable(chugsplash));
    }

    function test_delegateResolvedUpgrade_succeeds() external beforeEach {
        upgrade(payable(resolved));
    }

    function upgrade(address payable _proxy) internal {
        vm.prank(address(safeProxy));
        admin.upgrade(_proxy, address(implementation));

        address impl = admin.getProxyImplementation(_proxy);
        assertEq(impl, address(implementation));
    }

    function test_erc1967UpgradeAndCall_succeeds() external beforeEach {
        upgradeAndCall(payable(proxy));
    }

    function test_chugsplashUpgradeAndCall_succeeds() external beforeEach {
        upgradeAndCall(payable(chugsplash));
    }

    function test_delegateResolvedUpgradeAndCall_succeeds() external beforeEach {
        upgradeAndCall(payable(resolved));
    }

    function upgradeAndCall(address payable _proxy) internal {
        vm.prank(address(safeProxy));
        admin.upgradeAndCall(_proxy, address(implementation), abi.encodeWithSelector(SimpleStorage.set.selector, 1, 1));

        address impl = admin.getProxyImplementation(_proxy);
        assertEq(impl, address(implementation));

        uint256 got = SimpleStorage(address(_proxy)).get(1);
        assertEq(got, 1);
    }

    function test_onlyOwner_notOwner_reverts() external beforeEach {
        vm.expectRevert("Ownable: caller is not the owner");
        admin.changeProxyAdmin(payable(proxy), address(0));

        vm.expectRevert("Ownable: caller is not the owner");
        admin.upgrade(payable(proxy), address(implementation));

        vm.expectRevert("Ownable: caller is not the owner");
        admin.upgradeAndCall(payable(proxy), address(implementation), hex"");
    }

    function test_isUpgrading_succeeds() external beforeEach {
        assertEq(false, admin.isUpgrading());

        vm.prank(address(safeProxy));
        admin.setUpgrading(true);
        assertEq(true, admin.isUpgrading());
    }
}
