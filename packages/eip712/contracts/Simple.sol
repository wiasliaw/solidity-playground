// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./EIP712.sol";

contract Simple is EIP712 {
    uint256 private _value;

    bytes32 public CACHE_SET_HASH = keccak256("Set(uint256 value)");

    constructor() EIP712("Simple", "v1") {}

    function get() external view returns (uint256) {
        return _value;
    }

    function set(uint256 value, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 funcHash = keccak256(abi.encode(CACHE_SET_HASH, value));
        bytes32 signHash = keccak256(abi.encodePacked("\x19\x01", this.DOMAIN_SEPARATOR(), funcHash));
        address signer = ECDSA.recover(signHash, v, r, s);
        require(signer == msg.sender);
        _value = value;
    }
}
