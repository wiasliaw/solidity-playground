// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IStaking.sol";

contract SingleStaking is IStaking, Ownable, ReentrancyGuard {
    // library
    using SafeERC20 for IERC20;

    // token
    IERC20 public stakingToken;
    IERC20 public rewardsToken;

    // staking info
    uint256 public totalShares;
    uint256 public lastUpdateTime;
    uint256 public rewardRate;
    uint256 public rewardPerShareStored;

    // user
    mapping(address => User) public users;

    constructor(address stakingToken_, address rewardsToken_) Ownable() {
        stakingToken = IERC20(stakingToken_);
        rewardsToken = IERC20(rewardsToken_);
    }

    /**
     * Modifier
     */
    modifier updateStaking(address account) {
        // staking info
        rewardPerShareStored = this.rewardPerShare();
        lastUpdateTime = block.timestamp;

        // user
        if (account != address(0)) {
            User storage user = users[account];
            user.rewards = this.earned(account);
            user.snapshot = rewardPerShareStored;
        }
        _;
    }

    /**
     * View
     */
    /// @notice fetch pending reward of an account
    function earned(address account) external view override returns (uint256) {
        User storage user = users[account];
        return
            ((user.shares * (this.rewardPerShare() - user.snapshot)) / 1e18) +
            user.rewards;
    }

    /// @notice fetch price of rewards/shares
    function rewardPerShare() external view override returns (uint256) {
        if (totalShares == 0) {
            return rewardPerShareStored;
        }
        return
            rewardPerShareStored +
            ((block.timestamp - lastUpdateTime) * (rewardRate * 1e18)) /
            totalShares;
    }

    /**
     * User muable function
     */
    /// @notice stake staking token
    function deposit(uint256 amount_)
        external
        override
        nonReentrant
        updateStaking(msg.sender)
    {
        require(amount_ > 0);

        // user
        User storage user = users[msg.sender];
        user.shares = user.shares + amount_;
        user.snapshot = this.rewardPerShare();

        // total shares
        totalShares = totalShares + amount_;

        // transfer and event
        stakingToken.safeTransferFrom(msg.sender, address(this), amount_);
        emit Deposited(msg.sender, amount_, this.rewardPerShare());
    }

    /// @notice withdraw the staking token
    function withdraw(uint256 amount_)
        external
        override
        nonReentrant
        updateStaking(msg.sender)
    {
        require(amount_ > 0);

        // user
        User storage user = users[msg.sender];
        user.shares = user.shares - amount_;

        // total shares
        totalShares = totalShares - amount_;

        // transfer and event
        stakingToken.safeTransfer(msg.sender, amount_);
        emit Withdrawn(msg.sender, amount_, this.rewardPerShare());
    }

    /// @notice get reward of staking token
    function reward() external override nonReentrant updateStaking(msg.sender) {
        User storage user = users[msg.sender];
        uint256 rewards = user.rewards;
        if (rewards > 0) {
            user.rewards = 0;
            rewardsToken.safeTransfer(msg.sender, rewards);
        }
    }
}
