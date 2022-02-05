import { use, expect } from 'chai';
import { ethers, waffle } from 'hardhat';

import { Wallet } from 'ethers';
import { Simple } from '../dist/types';

use(waffle.solidity);

describe('Simple', () => {
  let user: Wallet;
  let contract: Simple;

  before(async () => {
    contract = await (await ethers.getContractFactory('Simple')).deploy() as Simple;
    user = (await (ethers as any).getSigners())[0];
  });

  it('set and get', async () => {
    // sign data
    const domain = {
      name: 'Simple',
      version: 'v1',
      chainId: ethers.provider.network.chainId,
      verifyingContract: contract.address.toString(),
    };

    const types = {
      Set: [
        {name: 'value', type: 'uint256'},
      ],
    };

    const val = {
      'value': ethers.BigNumber.from(33),
    };

    // sign
    const signature = await user._signTypedData(domain, types, val);
    const {v, r, s} = ethers.utils.splitSignature(signature);

    await contract.set(33, v, r, s);
    expect(await contract.get()).to.eq(33);
  });
});
