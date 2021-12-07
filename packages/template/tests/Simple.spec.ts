import { use, expect } from 'chai';
import { ethers, waffle } from 'hardhat';
import { Simple } from '../dist/types';

use(waffle.solidity);

describe('Simple', () => {
  let contract: Simple;

  before(async () => {
    contract = await (await ethers.getContractFactory('Simple')).deploy() as Simple;
  });

  it('set and get', async () => {
    await contract.set(33);
    expect(await contract.get()).to.eq(33);
  });
});
