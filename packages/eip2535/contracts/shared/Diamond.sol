// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";

import {DiamondCutFacet} from "./facets/DiamondCutFacet.sol";
import {OwnableFacet} from "./facets/OwnableFacet.sol";
import {LibDiamond} from "./libraries/LibDiamond.sol";
import {Bytes4Map} from "./libraries/Bytes4Map.sol";

contract Diamond is Proxy {
    constructor(address newOwner_) {
        LibDiamond._transferOwnership(newOwner_);
        LibDiamond._addDiamondFunctions(
            address(new DiamondCutFacet()),
            address(new OwnableFacet())
        );
    }

    function _implementation() internal view override returns (address) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        (bool exist, bytes32 data) = Bytes4Map.tryGet(ds.facetMetas, msg.sig);
        require(exist, "Diamond: Function does not exist");
        return address(bytes20(data));
    }
}
