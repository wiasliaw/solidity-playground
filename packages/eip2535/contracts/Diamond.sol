// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";

import {LibDiamond} from "./LibDiamond.sol";
import {Bytes4Map} from "./libraries/Bytes4Map.sol";

contract Diamond is Proxy {
    using Bytes4Map for Bytes4Map.Map;

    constructor(address newOwner_) {}

    function _implementation() internal view override returns (address) {
        LibDiamond.DiamondStorage storage ds = LibDiamond._diamondStorage();
        (bool exist, bytes32 data) = Bytes4Map.tryGet(
            ds.functionSelectors,
            msg.sig
        );
        require(exist, "Diamond: Function does not exist");
        return address(bytes20(data));
    }
}
