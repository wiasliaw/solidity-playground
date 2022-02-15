import { ethers, waffle } from 'hardhat';
import { expect, use } from 'chai';
import { mockFixture } from './shared';

import { Wallet } from 'ethers';
import { MockOwnableFacet } from '../dist/types';

use(waffle.solidity);

describe('OwnableFacet', () => {
  let user1: Wallet, user2: Wallet;
  let loadFixture: ReturnType<typeof waffle.createFixtureLoader>;

  let ownable: MockOwnableFacet;

  before('create fixture', async () => {
    [user1, user2] = await (ethers as any).getSigners();
    loadFixture = waffle.createFixtureLoader([user1, user2]);
  });

  beforeEach('deploy fixture', async () => {
    ({ ownable } = await loadFixture(mockFixture));
  });

  describe('#owner', () => {
    it('owner', async () => {
      expect(await ownable.owner()).eq(user1.address);
    });
  });

  describe('#transferOwnership', () => {
    it('should revert', async () => {
      await expect(ownable.connect(user2).transferOwnership(user1.address))
        .revertedWith('OwnableFacet: caller is not the owner');
      await expect(ownable.connect(user1).transferOwnership(ethers.constants.AddressZero))
        .revertedWith('OwnableFacet: new owner is the zero address');
    });

    it('success', async () => {
      await expect(ownable.connect(user1).transferOwnership(user2.address))
        .emit(ownable, 'OwnershipTransferred')
        .withArgs(user1.address, user2.address);
    });
  });
});
