// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EIP712 {
    // EIP712 Domain
    bytes32 private immutable CACHE_NAME;
    bytes32 private immutable CACHE_VERSION;
    uint256 private immutable CACHE_CHAIN_ID;
    address private immutable CACHE_THIS;

    // EIP712 Domain Separator
    bytes32 private immutable CACHE_DOMAIN_SEPARATOR;

    // EIP712Domain hash
    bytes32 constant EIP712DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    constructor(string memory name_, string memory version_) {
        bytes32 hashed_name = keccak256(bytes(name_));
        bytes32 hashed_version = keccak256(bytes(version_));

        CACHE_NAME = hashed_name;
        CACHE_VERSION = hashed_version;
        CACHE_CHAIN_ID = block.chainid;
        CACHE_THIS = address(this);

        /**
         * Hash Signature
         * [0]: function signature hash
         * [1-?]: funciton argument
         */
        CACHE_DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                hashed_name,
                hashed_version,
                block.chainid,
                address(this)
            )
        );
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return CACHE_DOMAIN_SEPARATOR;
    }
}
