import { use, expect } from 'chai';
import { ethers, waffle } from 'hardhat';
import { Simple } from '../dist/types';

use(waffle.solidity);

describe('EIP712 Simeple', () => {
  let simple: Simple;

  before(async () => {
    simple = await (await ethers.getContractFactory('Simple')).deploy() as Simple;
  });

  it('permit', async () => {
    const [deployer, signer] = await ethers.getSigners();

    const domain = {
      name: 'Simple',
      version: 'v1',
      chainId: ethers.provider.network.chainId,
      verifyingContract: simple.address.toString(),
    };

    const types = {
      Permit: [
        {name: 'editor', type: 'address'},
      ],
    };

    const val = {
      'editor': signer.address.toString(),
    };

    const signature = await deployer._signTypedData(domain, types, val);
    const sig = ethers.utils.splitSignature(signature);

    await simple.connect(deployer).permit(
      signer.address.toString(),
      sig.v,
      sig.r,
      sig.s,
    );
  });
});
