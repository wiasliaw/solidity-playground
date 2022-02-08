// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Simple {
    uint256 private _val;

    function get() external view returns (uint256) {
        return _val;
    }

    function set(uint256 val_) external {
        _val = val_;
    }
}
