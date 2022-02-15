// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDiamondCut} from "../interfaces/IDiamonCut.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract DiamondCutFacet is IDiamondCut {
    function diamondCut(
        FacetCut[] calldata diamondCut_,
        address init_,
        bytes calldata calldata_
    ) external override {
        LibDiamond._onlyOwner();
        LibDiamond._diamondCut(diamondCut_, init_, calldata_);
    }
}
