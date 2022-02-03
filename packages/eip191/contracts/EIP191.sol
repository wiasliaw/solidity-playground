// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "hardhat/console.sol";

contract EIP191 {
    function verifyMessage(
        bytes memory str,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external view returns (bool) {
        bytes32 hash = ECDSA.toEthSignedMessageHash(str);
        address addr = ecrecover(hash, v, r, s);
        console.log(addr);
        return msg.sender == addr;
    }
}
