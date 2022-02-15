// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

import {IDiamondCut} from "../interfaces/IDiamonCut.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import {Bytes4Map} from "./Bytes4Map.sol";

library LibDiamond {
    using Address for address;
    using Bytes4Map for Bytes4Map.Map;

    bytes32 private constant DIAMOND_STORAGE = keccak256("diamond.diamondCut");

    struct DiamondStorage {
        address owner;
        Bytes4Map.Map facetMetas;
    }

    function diamondStorage()
        internal
        pure
        returns (DiamondStorage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE;
        assembly {
            ds.slot := position
        }
    }

    /** ***** ***** ***** ***** *****
     * Owner
     ***** ***** ***** ***** ***** */
    function _owner() internal view returns (address) {
        return diamondStorage().owner;
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner();
        diamondStorage().owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _onlyOwner() internal view {
        require(
            msg.sender == LibDiamond._owner(),
            "OwnableFacet: caller is not the owner"
        );
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /** ***** ***** ***** ***** *****
     * Diamond
     ***** ***** ***** ***** ***** */
    function _diamondCut(
        IDiamondCut.FacetCut[] memory diamondCut_,
        address init_,
        bytes memory calldata_
    ) internal {
        // operations for facet and function selectors
        for (uint256 index = 0; index < diamondCut_.length; index++) {
            IDiamondCut.FacetCutAction action = diamondCut_[index].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                _addFunctions(
                    diamondCut_[index].facetAddress,
                    diamondCut_[index].functionSelectors
                );
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                _replaceFunctions(
                    diamondCut_[index].facetAddress,
                    diamondCut_[index].functionSelectors
                );
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                _removeFunctions(
                    diamondCut_[index].facetAddress,
                    diamondCut_[index].functionSelectors
                );
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }
        // init function of facet
        _initDiamondCut(init_, calldata_);
        emit DiamondCut(diamondCut_, init_, calldata_);
    }

    function _addFunctions(
        address facetAddress_,
        bytes4[] memory functionSelectors_
    ) internal {
        require(
            functionSelectors_.length > 0,
            "LibDiamondCut: No selectors in facet to cut"
        );
        require(
            facetAddress_ != address(0),
            "LibDiamondCut: Add facet can't be address(0)"
        );
        require(
            facetAddress_.isContract(),
            "LibDiamondCut: Add facet has no code"
        );

        // fetch storage
        DiamondStorage storage ds = diamondStorage();

        // add functions
        for (uint256 index = 0; index < functionSelectors_.length; index++) {
            bytes4 selector = functionSelectors_[index];
            require(
                !ds.facetMetas.contains(selector),
                "LibDiamondCut: Can't add function that already exists"
            );
            ds.facetMetas.set(selector, bytes32(bytes20(facetAddress_)));
        }
    }

    function _replaceFunctions(
        address facetAddress_,
        bytes4[] memory functionSelectors_
    ) internal {
        require(
            functionSelectors_.length > 0,
            "LibDiamondCut: No selectors in facet to cut"
        );
        require(
            facetAddress_ != address(0),
            "LibDiamondCut: Replace facet can't be address(0)"
        );
        require(
            facetAddress_.isContract(),
            "LibDiamondCut: Replace facet has no code"
        );

        // fetch storage
        DiamondStorage storage ds = diamondStorage();

        // replace function
        for (uint256 index = 0; index < functionSelectors_.length; index++) {
            bytes4 selector = functionSelectors_[index];
            (bool exist, bytes32 data) = ds.facetMetas.tryGet(selector);
            address oldFacetAddress = address(bytes20(data));
            require(
                oldFacetAddress != address(this),
                "LibDiamondCut: Can't replace immutable function"
            );
            require(
                oldFacetAddress != facetAddress_,
                "LibDiamondCut: Can't replace function with same function"
            );
            require(
                exist,
                "LibDiamondCut: Can't replace function that doesn't exist"
            );
            ds.facetMetas.set(selector, bytes32(bytes20(facetAddress_)));
        }
    }

    function _removeFunctions(
        address facetAddress_,
        bytes4[] memory functionSelectors_
    ) internal {
        require(
            functionSelectors_.length > 0,
            "LibDiamondCut: No selectors in facet to cut"
        );
        require(
            facetAddress_ == address(0),
            "LibDiamondCut: Remove facet address must be address(0)"
        );

        // fetch storage
        DiamondStorage storage ds = diamondStorage();

        // remove function
        for (uint256 index = 0; index < functionSelectors_.length; index++) {
            bytes4 selector = functionSelectors_[index];
            (bool exist, bytes32 data) = ds.facetMetas.tryGet(selector);
            address oldFacetAddress = address(bytes20(data));
            require(
                exist,
                "LibDiamondCut: Can't remove function that doesn't exist"
            );
            require(
                oldFacetAddress != address(this),
                "LibDiamondCut: Can't remove immutable function"
            );
            ds.facetMetas.remove(selector);
        }
    }

    function _initDiamondCut(address init_, bytes memory calldata_) internal {
        if (init_ == address(0)) {
            require(calldata_.length == 0);
        } else {
            require(calldata_.length > 0);
            require(init_.isContract());
            init_.functionDelegateCall(calldata_);
        }
    }

    function _addDiamondFunctions(
        address diamondCutFacet_,
        address ownershipFacet_
    ) internal {
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](2);
        // diamondCut
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: diamondCutFacet_,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });

        // ownershipFacet
        functionSelectors = new bytes4[](2);
        functionSelectors[0] = IERC173.transferOwnership.selector;
        functionSelectors[1] = IERC173.owner.selector;
        cut[1] = IDiamondCut.FacetCut({
            facetAddress: ownershipFacet_,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });

        // diamondCut function
        _diamondCut(cut, address(0), "");
    }

    event DiamondCut(
        IDiamondCut.FacetCut[] diamondCut_,
        address init_,
        bytes calldata_
    );
}
