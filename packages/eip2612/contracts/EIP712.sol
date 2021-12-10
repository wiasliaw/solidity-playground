// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/draft-EIP712.sol
contract EIP712 {
    address private immutable CACHED_THIS;
    uint256 private immutable CACHED_CHAIN_ID;
    bytes32 private immutable CACHED_NAME;
    bytes32 private immutable CACHED_VERSION;
    bytes32 private immutable CACHED_DOMAIN_SEPARATOR;

    // hashed type
    bytes32 private constant TYPE_EIP712DOMAIN =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));

        CACHED_THIS = address(this);
        CACHED_CHAIN_ID = block.chainid;
        CACHED_NAME = hashedName;
        CACHED_VERSION = hashedVersion;
        CACHED_DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                TYPE_EIP712DOMAIN,
                hashedName,
                hashedVersion,
                block.chainid,
                address(this)
            )
        );
    }

    function _domainSeparator() internal view returns (bytes32) {
        return CACHED_DOMAIN_SEPARATOR;
    }
}
