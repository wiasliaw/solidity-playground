// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

import {IDiamondCut} from "./interfaces/IDiamondCut.sol";
import {Bytes4Map} from "./libraries/Bytes4Map.sol";

library LibDiamond {
    using Address for address;
    using Bytes4Map for Bytes4Map.Map;

    bytes32 constant DIAMOND_STORAGE =
        keccak256("diamond.standard.diamond_storage");

    struct DiamondStorage {
        address owner;
        Bytes4Map.Map functionSelectors;
        bytes4[] supportedInterfaceId;
    }

    /// @dev return storage pointer of DS
    function _diamondStorage()
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
    /// @dev return owner address
    function _owner() internal view returns (address) {
        return _diamondStorage().owner;
    }

    /// @dev transfer ownership
    function _transferOwnership(address newOwner_) internal {
        _diamondStorage().owner = newOwner_;
    }

    /// @dev onlyOwner hook
    function _onlyOwner() internal view {
        require(msg.sender == _diamondStorage().owner);
    }

    /** ***** ***** ***** ***** *****
     * Owner
     ***** ***** ***** ***** ***** */
    /// @dev see {EIP 2535} diamondCut
    function _diamondCut(
        IDiamondCut.FacetCut[] memory diamondCut_,
        address init_,
        bytes memory calldata_
    ) internal {
        // operations for facet and function selectors
        for (uint256 i = 0; i < diamondCut_.length; i++) {
            IDiamondCut.FacetCutAction action = diamondCut_[i].action;
            if (action == IDiamondCut.FacetCutAction.Add) {
                _add(
                    diamondCut_[i].facetAddress,
                    diamondCut_[i].functionSelectors
                );
            } else if (action == IDiamondCut.FacetCutAction.Replace) {
                _replace(
                    diamondCut_[i].facetAddress,
                    diamondCut_[i].functionSelectors
                );
            } else if (action == IDiamondCut.FacetCutAction.Remove) {
                _remove(
                    diamondCut_[i].facetAddress,
                    diamondCut_[i].functionSelectors
                );
            } else {
                revert("LibDiamondCut: Incorrect FacetCutAction");
            }
        }

        // init function of facet
        _initDiamondCut(init_, calldata_);
    }

    /// @dev add a facet and its function selectors
    function _add(address facetAddress_, bytes4[] memory functionSelectors_)
        internal
    {
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
        DiamondStorage storage ds = _diamondStorage();

        // add functions
        for (uint256 i = 0; i < functionSelectors_.length; i++) {
            bytes4 selector = functionSelectors_[i];
            require(
                !ds.functionSelectors.contains(selector),
                "LibDiamondCut: Can't add function that already exists"
            );
            ds.functionSelectors.set(selector, bytes32(bytes20(facetAddress_)));
        }
    }

    /// @dev replace a facet and its function selectors
    function _replace(address facetAddress_, bytes4[] memory functionSelectors_)
        internal
    {
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
        DiamondStorage storage ds = _diamondStorage();

        // replace function
        for (uint256 i = 0; i < functionSelectors_.length; i++) {
            bytes4 selector = functionSelectors_[i];
            (bool exist, bytes32 data) = ds.functionSelectors.tryGet(selector);
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
            ds.functionSelectors.set(selector, bytes32(bytes20(facetAddress_)));
        }
    }

    /// @dev remove a facet and its function selectors
    function _remove(address facetAddress_, bytes4[] memory functionSelectors_)
        internal
    {
        require(
            functionSelectors_.length > 0,
            "LibDiamondCut: No selectors in facet to cut"
        );
        require(
            facetAddress_ == address(0),
            "LibDiamondCut: Remove facet address must be address(0)"
        );

        // fetch storage
        DiamondStorage storage ds = _diamondStorage();

        // remove function
        for (uint256 i = 0; i < functionSelectors_.length; i++) {
            bytes4 selector = functionSelectors_[i];
            (bool exist, bytes32 data) = ds.functionSelectors.tryGet(selector);
            address oldFacetAddress = address(bytes20(data));
            require(
                exist,
                "LibDiamondCut: Can't remove function that doesn't exist"
            );
            require(
                oldFacetAddress != address(this),
                "LibDiamondCut: Can't remove immutable function"
            );
            ds.functionSelectors.remove(selector);
        }
    }

    /// @dev init
    function _initDiamondCut(address init_, bytes memory calldata_) internal {
        if (init_ == address(0)) {
            require(calldata_.length == 0);
        } else {
            require(calldata_.length > 0);
            require(init_.isContract());
            init_.functionDelegateCall(calldata_);
        }
    }
}
