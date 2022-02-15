// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bar {
    bytes32 private constant BAR = keccak256("value");

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
        return _slot(BAR).value;
    }

    /// @dev sign_hash 0x352d3fba
    function setBar(uint256 value) external {
        _slot(BAR).value = value;
    }
}
