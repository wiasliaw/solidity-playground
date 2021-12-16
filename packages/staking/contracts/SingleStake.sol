// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract SingleStake {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct UserInfo {
        uint256 shares;
        uint256 lastDepositedTime;
    }

    // global info
    IERC20 public token;
    uint256 public totalShares;
    uint256 public blockReward;

    // user info
    mapping(address => UserInfo) public userInfo;

    constructor(IERC20 token_, uint256 blockReward_) {
        token = token_;
        blockReward = blockReward_;
    }

    function deposit(uint256 amount_) external {
        UserInfo storage user = userInfo[msg.sender];

        // handle pending reward
        if (user.shares > 0) {
            user.shares =
                user.shares +
                (user.shares * blockReward) /
                totalShares;
        }

        // deposit
        if (amount_ > 0) {
            token.safeTransferFrom(msg.sender, address(this), amount_);
            user.shares = user.shares + amount_;
            user.lastDepositedTime = block.timestamp;
            totalShares = totalShares + amount_;
        }
    }

    function withdraw(uint256 shares_) external {
        UserInfo storage user = userInfo[msg.sender];
        require(shares_ > 0 && shares_ <= user.shares);

        // handle pending reward
        uint256 currentAmount = 0;
        if (user.shares > 0) {
            currentAmount = (user.shares * blockReward) / totalShares;
        }

        // withdraw
        currentAmount = currentAmount + shares_;
        user.shares = user.shares - shares_;
        user.lastDepositedTime = 0;
        token.safeTransfer(msg.sender, currentAmount);
    }
}
