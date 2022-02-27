// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IDiamondLoupe.sol";
import {LibDiamond} from "../LibDiamond.sol";
import {Bytes4Map} from "../libraries/Bytes4Map.sol";

contract DiamondLoupeFacet is IDiamondLoupe {
    using Bytes4Map for Bytes4Map.Map;

    function facets() external view override returns (Facet[] memory facets_) {
        LibDiamond.DiamondStorage storage ds = LibDiamond._diamondStorage();
        uint256 length = ds.functionSelectors.length();
        facets_ = new Facet[](length);
        // amount of facet
        uint256 numOfFacet;
        // amount of selector from a facet
        uint256[] memory numOfSelector = new uint256[](length);

        // loop function selector
        for (uint256 i = 0; i < length; i++) {
            // get (selector, address) by index
            (bytes4 selector, bytes32 data) = ds.functionSelectors.at(i);
            address addr = address(bytes20(data));

            // loop facet
            bool continueLoop = false;
            for (uint256 j = 0; j < numOfFacet; j++) {
                if (facets_[j].facetAddress == addr) {
                    facets_[j].functionSelectors[numOfSelector[j]] = selector;
                    numOfSelector[j]++;
                    continueLoop = true;
                    break;
                }
            }
            // exist
            if (continueLoop) {
                continueLoop = false;
                continue;
            }
            // not exist
            facets_[numOfFacet].facetAddress = addr;
            facets_[numOfFacet].functionSelectors = new bytes4[](length);
            facets_[numOfFacet].functionSelectors[0] = selector;
            numOfSelector[numOfFacet] = 1;
            numOfFacet++;
        }
        // set array's length
        assembly {
            mstore(facets_, 0)
        }
    }

    function facetFunctionSelectors(address facet_)
        external
        view
        override
        returns (bytes4[] memory functionSelectorArray)
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond._diamondStorage();
        uint256 length = ds.functionSelectors.length();
        functionSelectorArray = new bytes4[](length);
        uint256 numOfSelector;

        // loop function selector
        for (uint256 i = 0; i < length; i++) {
            // get (selector, address) by index
            (bytes4 selector, bytes32 data) = ds.functionSelectors.at(i);
            address addr = address(bytes20(data));

            // push into array
            if (addr == facet_) {
                functionSelectorArray[numOfSelector] = selector;
                numOfSelector++;
            }
        }

        // set array's length
        assembly {
            mstore(functionSelectorArray, 0)
        }
    }

    function facetAddresses()
        external
        view
        override
        returns (address[] memory facetAddressArray)
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond._diamondStorage();
        uint256 length = ds.functionSelectors.length();
        facetAddressArray = new address[](length);
        uint256 numOfFacet = 0;

        // loop function selector
        for (uint256 i = 0; i < length; i++) {
            // get (selector, address) by index
            (, bytes32 data) = ds.functionSelectors.at(i);
            address addr = address(bytes20(data));

            // loop array to check if exist
            bool continueLoop = false;
            for (uint256 j; j < numOfFacet; j++) {
                if (addr == facetAddressArray[j]) {
                    continueLoop = true;
                    break;
                }
            }

            // exist => continue
            if (continueLoop) {
                continueLoop = false;
                continue;
            }

            // not exist => record into array
            facetAddressArray[numOfFacet] = addr;
            numOfFacet++;
        }

        // set array's length
        assembly {
            mstore(facetAddressArray, numOfFacet)
        }
    }

    function facetAddress(bytes4 functionSelector_)
        external
        view
        override
        returns (address)
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond._diamondStorage();
        (, bytes32 data) = ds.functionSelectors.tryGet(functionSelector_);
        return address(bytes20(data));
    }
}
