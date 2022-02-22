import { expect } from 'chai';
import { ethers } from 'hardhat';

import { BoxV1, BoxV2, UUPSProxy } from '../dist/types';

describe('Integration', () => {
  let b1: BoxV1;
  let b2: BoxV2;
  let proxy: UUPSProxy;

  before(async () => {
    b1 = await (await ethers.getContractFactory('BoxV1')).deploy() as BoxV1;
    await b1.deployed();
    b2 = await (await ethers.getContractFactory('BoxV2')).deploy() as BoxV2;
    await b2.deployed();
    proxy = await (await ethers.getContractFactory('UUPSProxy'))
      .deploy(b1.address, b1.interface.encodeFunctionData('initialize')) as UUPSProxy;
    await proxy.deployed();
  });

  it('get/set', async () => {
    const instance = b1.attach(proxy.address);
    await instance.set1(33);
    expect(await instance.get()).eq(33);
  });

  it('upgrade get/set', async () => {
    const instance = b2.attach(proxy.address);
    await instance.upgradeTo(b2.address);
    await instance.set2(66);
    expect(await instance.get()).eq(66);
  });
});
