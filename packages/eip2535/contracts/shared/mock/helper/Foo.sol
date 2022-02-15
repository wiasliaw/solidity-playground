// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Foo {
    bytes32 private constant FOO = keccak256("value");

    struct UintSlot {
        uint256 value;
    }

    function _slot(bytes32 slot) internal pure returns (UintSlot storage s) {
        assembly {
            s.slot := slot
        }
    }

    /// @dev sign_hash 0x6d4ce63c
    function get() external view returns (uint256) {
        return _slot(FOO).value;
    }

    /// @dev sign_hash 0xdc80035d
    function setFoo(uint256 value) external {
        _slot(FOO).value = value;
    }
}
