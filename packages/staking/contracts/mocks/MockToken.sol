// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// edited from: https://bscscan.com/address/0x0e09fabb73bd3ade0a17ecc321fd13a19e81ce82
// remove functionality of voting
contract MockToken is ERC20("MockToken", "MT"), Ownable {
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
