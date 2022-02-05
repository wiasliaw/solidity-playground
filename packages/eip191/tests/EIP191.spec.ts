import { use, expect } from 'chai';
import { ethers, waffle } from 'hardhat';

import { EIP191 } from '../dist/types';

use(waffle.solidity);

describe('EIP191', () => {
  let contract: EIP191;

  before(async () => {
    contract = await (await ethers.getContractFactory('EIP191')).deploy() as EIP191;
  });

  it('verifyMessage', async () => {
    const { keccak256, toUtf8Bytes, arrayify } = ethers.utils;
    const [user] = await ethers.getSigners();
    const data = keccak256(toUtf8Bytes('hello world'));

    /**
     * Hash with EIP191
     * - equal to the result of `ECDSA.toEthSignedMessageHash`
     */
    const messageBuffer = Buffer.from(data.substring(2), 'hex');
    const prefix = Buffer.from(`\x19Ethereum Signed Message:\n${messageBuffer.length}`);
    const hash = keccak256(Buffer.concat([prefix, messageBuffer]));

    /**
     * Sign the data
     * - `eth_sign` or `personal_sign`
     *   - two rpc method is the same
     * - ethers.Wallet.signMessage
     *   - should use `arrayify`
     */
    const signedData1 = await ethers.provider.send('eth_sign', [user.address.toString(), data]);
    const signedData2 = await user.signMessage(arrayify(data));

    let {v, r, s} = ethers.utils.splitSignature(signedData1);
    expect(await contract.verifyMessage(data, v, r, s))
      .eq(true);

    ({v, r, s} = ethers.utils.splitSignature(signedData2));
    expect(await contract.verifyMessage(data, v, r, s))
      .eq(true);
  });
});
