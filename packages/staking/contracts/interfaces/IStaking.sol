// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStaking {
    // struct
    struct User {
        uint256 shares;
        uint256 rewards;
        uint256 snapshot;
    }

    // function
    function deposit(uint256 amount_) external;

    function withdraw(uint256 amount_) external;

    function reward() external;

    function earned(address account) external view returns (uint256);

    function rewardPerShare() external view returns (uint256);

    // event
    event Deposited(address indexed sender_, uint256 amount_, uint256 rps_);
    event Withdrawn(address indexed sender_, uint256 amount_, uint256 rps_);
}
