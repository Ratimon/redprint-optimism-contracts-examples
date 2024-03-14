// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployScript, IDeployer} from "@script/deployer/DeployScript.sol";
import {DeployerFunctions} from "@script/deployer/DeployerFunctions.sol";

import { SafeProxyFactory } from "@safe-contracts/proxies/SafeProxyFactory.sol";
import { Safe } from "@safe-contracts/Safe.sol";
import { SafeProxy } from "@safe-contracts/proxies/SafeProxy.sol";


contract DeploySafeScript is DeployScript {
    using DeployerFunctions for IDeployer;

    address owner;

    // function deploy() external returns (SafeProxyFactory safeProxyFactory_, Safe safeSingleton_ , SafeProxy safeProxy_) {
    function deploy() external returns (Safe) {

        // string memory mnemonic = vm.envString("MNEMONIC");
        // uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
        // owner = vm.envOr("DEPLOYER", vm.addr(ownerPrivateKey));

        // These are the standard create2 deployed contracts. First we'll check if they are deployed,
        // if not we'll deploy new ones, though not at these addresses.
        address safeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
        address safeSingleton = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;


        // safeProxyFactory.code.length == 0
        //     ? safeProxyFactory_ = SafeProxyFactory(deployer.deploy_SafeProxyFactory("SafeProxyFactory"))
        //     : safeProxyFactory_ = SafeProxyFactory(safeProxyFactory);


        return Safe(deployer.deploy_Safe("SafeSingleton"));
        // safeSingleton.code.length == 0
        //     ? safeSingleton_ = Safe(deployer.deploy_Safe("SafeSingleton"))
        //     : safeSingleton_ = Safe(payable(safeSingleton));

        // safeProxy_ = SafeProxy(deployer.deploy_SystemOwnerSafe(
        //     "SystemOwnerSafe",
        //     "SafeProxyFactory",
        //     "SafeSingleton",
        //     address(owner)
        // ));

        
        // return SafeProxy(deployer.deploy_SystemOwnerSafe(
        //     "SystemOwnerSafe",
        //     "SafeProxyFactory",
        //     "SafeSingleton",
        //     address(owner)
        // ));
    }

//     /// @notice Deploy the Safe
//     function deploySafe() public broadcast returns (address addr_) {

//         console.log("Deploying Safe");
//         (SafeProxyFactory safeProxyFactory, Safe safeSingleton) = _getSafeFactory();

//         address[] memory signers = new address[](1);
//         signers[0] = msg.sender;

//         bytes memory initData = abi.encodeWithSelector(
//             Safe.setup.selector, signers, 1, address(0), hex"", address(0), address(0), 0, address(0)
//         );
//         address safe = address(safeProxyFactory.createProxyWithNonce(address(safeSingleton), initData, block.timestamp));

//         save("SystemOwnerSafe", address(safe));
//         console.log("New SystemOwnerSafe deployed at %s", address(safe));
//         addr_ = safe;
//     }

//     function _getSafeFactory() internal returns (SafeProxyFactory safeProxyFactory_, Safe safeSingleton_) {
//         // These are the standard create2 deployed contracts. First we'll check if they are deployed,
//         // if not we'll deploy new ones, though not at these addresses.
//         address safeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
//         address safeSingleton = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;

//         safeProxyFactory.code.length == 0
//             ? safeProxyFactory_ = new SafeProxyFactory()
//             : safeProxyFactory_ = SafeProxyFactory(safeProxyFactory);

//         safeSingleton.code.length == 0 ? safeSingleton_ = new Safe() : safeSingleton_ = Safe(payable(safeSingleton));

//         save("SafeProxyFactory", address(safeProxyFactory_));
//         save("SafeSingleton", address(safeSingleton_));

//     }


}
