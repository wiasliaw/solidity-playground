// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {OwnableFacet} from "../facets/OwnableFacet.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract MockOwnableFacet is OwnableFacet {
    constructor(address owner_) {
        LibDiamond._transferOwnership(owner_);
    }
}
