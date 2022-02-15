// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DiamondCutFacet} from "../facets/DiamondCutFacet.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import {Bytes4Map} from "../libraries/Bytes4Map.sol";

contract MockDiamondCutFacet is DiamondCutFacet {
    constructor(address owner_) {
        LibDiamond._transferOwnership(owner_);
    }

    function addFunction(
        address facetAddress_,
        bytes4[] memory functionSelectors_
    ) external {
        LibDiamond._addFunctions(facetAddress_, functionSelectors_);
    }

    function replaceFunctions(
        address facetAddress_,
        bytes4[] memory functionSelectors_
    ) external {
        LibDiamond._replaceFunctions(facetAddress_, functionSelectors_);
    }

    function removeFunctions(
        address facetAddress_,
        bytes4[] memory functionSelectors_
    ) external {
        LibDiamond._removeFunctions(facetAddress_, functionSelectors_);
    }

    function get(bytes4 selector) external view returns (address) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        (bool exist, bytes32 data) = Bytes4Map.tryGet(ds.facetMetas, selector);
        require(exist);
        return address(bytes20(data));
    }
}
