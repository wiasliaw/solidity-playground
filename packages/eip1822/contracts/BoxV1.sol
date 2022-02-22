// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

contract BoxV1 is Initializable, UUPSUpgradeable, Ownable {
    uint256 private _value;

    constructor() initializer {}

    function initialize() public initializer {
        _transferOwnership(msg.sender);
    }

    function get() external view returns (uint256) {
        return _value;
    }

    function set1(uint256 value) external onlyOwner {
        _value = value;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyOwner
    {}
}
