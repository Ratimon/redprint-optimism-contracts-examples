// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { console } from "@forge-std/console.sol";
import { Enum } from "@safe-contracts/Safe.sol";
import { MultiSend, Utils } from "@script-multisig/Utils.s.sol";
import "@script-multisig/Constants.s.sol";



contract initializeSuperchainConfigScript is Utils {

    function run() external {

        bytes memory transactions;
        uint8 isDelegateCall = 0;
        uint256 value = 0;

        /** TODO  complete */
        uint256 chainId = CHAIN_ETHEREUM;
        uint208 placeholder = uint208(uint256(1e9));
        address to = address(0);
        /** END  complete */

        bytes memory data = abi.encodeWithSelector(MockERC20Pausable.pause.selector, placeholder);
        uint256 dataLength = data.length;
        bytes memory internalTx = abi.encodePacked(isDelegateCall, to, value, dataLength, data);
        transactions = abi.encodePacked(transactions, internalTx);

    }
}
