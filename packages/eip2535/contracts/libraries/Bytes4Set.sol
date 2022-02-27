// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Bytes4Set {
    struct Set {
        bytes4[] _values;
        mapping(bytes4 => uint256) _indexes;
    }

    function add(Set storage set, bytes4 value) internal returns (bool) {
        if (!contains(set, value)) {
            set._values.push(value);
            // index starts from 1
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(Set storage set, bytes4 value) internal returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // fetch real index
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // swap lastValue to toDelete if not the last
            if (toDeleteIndex != lastIndex) {
                bytes4 lastValue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex;
            }

            // deletes
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    function contains(Set storage set, bytes4 value)
        internal
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function length(Set storage set) internal view returns (uint256) {
        return set._values.length;
    }

    function at(Set storage set, uint256 index) internal view returns (bytes4) {
        return set._values[index];
    }

    function values(Set storage set) internal view returns (bytes4[] memory) {
        return set._values;
    }
}
