// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Bytes4Set.sol";

library Bytes4Map {
    using Bytes4Set for Bytes4Set.Set;

    struct Map {
        Bytes4Set.Set _keys;
        mapping(bytes4 => bytes32) _values;
    }

    function set(
        Map storage map,
        bytes4 key,
        bytes32 value
    ) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    function remove(Map storage map, bytes4 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    function contains(Map storage map, bytes4 key)
        internal
        view
        returns (bool)
    {
        return map._keys.contains(key);
    }

    function length(Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    function at(Map storage map, uint256 index)
        internal
        view
        returns (bytes4, bytes32)
    {
        bytes4 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    function tryGet(Map storage map, bytes4 key)
        internal
        view
        returns (bool, bytes32)
    {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }
}
