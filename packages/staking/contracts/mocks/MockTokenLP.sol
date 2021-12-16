// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// edit from: https://bscscan.com/address/0x009cf7bc57584b7998236eff51b98a168dcea9b0
// remove functionality of voting
contract MockTokenLP is ERC20("MockToken LP", "MT LP"), Ownable {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _from ,uint256 _amount) public onlyOwner {
        _burn(_from, _amount);
    }
}
