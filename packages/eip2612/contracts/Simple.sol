// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./EIP712.sol";

contract Simple is EIP712 {
    address private _owner;
    uint256 private _value;
    mapping(address => bool) private _allowance;

    bytes32 private _PERMIT_TYPEHASH =
        keccak256("Permit(address editor)");

    constructor() EIP712('Simple', 'v1') {
        _owner = msg.sender;
    }

    function set(uint256 nv) public {
        require(msg.sender == _owner);
        _value = nv;
    }

    function setFrom(uint256 nv) public {
        require(_allowance[msg.sender]);
        _value = nv;
        _allowance[msg.sender] = false;
    }

    function get() public view returns (uint256) {
        return _value;
    }

    function approve(address editor) public returns (bool) {
        require(msg.sender == _owner);
        _allowance[editor] = true;
        return true;
    }

    function allowance(address addr) public view returns (bool) {
        return _allowance[addr];
    }

    function permit(
        address editor,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, editor));
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _domainSeparator(), structHash));
        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == msg.sender);
        _allowance[editor] = true;
    }
}
