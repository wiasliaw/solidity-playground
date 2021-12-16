import { use, expect } from 'chai';
import hre, { ethers } from 'hardhat';
import { SingleStake, MockToken } from '../dist/types';

use(hre.waffle.solidity);

(async () => {
  let admin: any;
  let token: MockToken;
  let stake: SingleStake;

  before(async () => {
    [admin] = await ethers.getSigners();

    token = await (await hre.ethers.getContractFactory('MockToken'))
      .deploy() as MockToken;
    await token.deployed();

    stake = await (await hre.ethers.getContractFactory('SingleStake'))
      .deploy(token.address, 1) as SingleStake;
    await stake.deployed();

    token.connect(admin).mint(admin.address, 30000);
    token.connect(admin).transfer(stake.address, 10000);
  });

  it('test', async () => {
    try {
      // allowance
      await token.connect(admin).approve(stake.address, 20000);

      // 1
      await stake.connect(admin).deposit(10000);
      console.log((await stake.userInfo(admin.address)).shares);

      // 2
      await stake.connect(admin).deposit(10000);
      console.log((await stake.userInfo(admin.address)).shares);

      // 3
      await stake.connect(admin).withdraw(10000);
      console.log(await stake.userInfo(admin.address));
      console.log(await token.balanceOf(admin.address));

      // // 4
      await stake.connect(admin).withdrawAll();
      console.log(await stake.userInfo(admin.address));
      console.log(await token.balanceOf(admin.address));
    } catch (err) {
      throw err;
    }
  });
})();
