// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IERC173.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

contract OwnableFacet is IERC173 {
    function owner() external view override returns (address) {
        return LibDiamond._owner();
    }

    function transferOwnership(address newOwner_) external override {
        require(
            newOwner_ != address(0),
            "OwnableFacet: new owner is the zero address"
        );
        LibDiamond._onlyOwner();
        LibDiamond._transferOwnership(newOwner_);
    }
}
