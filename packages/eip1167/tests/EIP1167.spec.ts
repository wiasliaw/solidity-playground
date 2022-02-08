import { use, expect } from 'chai';
import { ethers, waffle } from 'hardhat';

import { Wallet } from 'ethers';
import { EIP1167, Simple } from '../dist/types';

use(waffle.solidity);

describe('EIP1167', () => {
  let logic: Simple;
  let proxy: Simple;

  before(async () => {
    logic = await (await ethers.getContractFactory('Simple')).deploy() as Simple;
    await logic.deployed();

    const p = await (await ethers.getContractFactory('EIP1167')).deploy(
      logic.address,
    ) as EIP1167;
    await p.deployed();

    proxy = logic.attach(p.address);
  });

  it('set and get', async () => {
    await proxy.set(33);
    expect(await proxy.get()).to.eq(33);
  });
});
