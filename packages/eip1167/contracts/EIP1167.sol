// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EIP1167 {
    address private immutable _impl;

    constructor(address impl_) {
        _impl = impl_;
    }

    fallback() external payable {
        _fallback(_impl);
    }

    function _fallback(address impl_) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), impl_, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
