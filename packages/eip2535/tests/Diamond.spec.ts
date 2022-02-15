import { ethers, waffle } from 'hardhat';
import { expect, use } from 'chai';
import { integrationFixture } from './shared';

import { Wallet } from 'ethers';
import {
  Diamond,
  DiamondCutFacet,
  OwnableFacet,
  Foo,
} from '../dist/types';

use(waffle.solidity);

describe('Diamond', () => {
  let user1: Wallet, user2: Wallet;
  let loadFixture: ReturnType<typeof waffle.createFixtureLoader>;

  let diamond: Diamond;

  before('create fixture', async () => {
    [user1, user2] = await (ethers as any).getSigners();
    loadFixture = waffle.createFixtureLoader([user1, user2]);
  });

  beforeEach('deploy fixture', async () => {
    ({ diamond } = await loadFixture(integrationFixture));
  });

  describe('diamond ownership', () => {
    it('owner', async () => {
      const ownable = await ethers
        .getContractAt('OwnableFacet', diamond.address) as OwnableFacet;
      expect(await ownable.owner()).eq(user1.address);
    });
  });

  describe('diamond cut', () => {
    beforeEach(async () => {
      const foo = await (await ethers.getContractFactory('Foo')).deploy() as Foo;

      // interface to Faucet struct
      const faucet = foo.interface.fragments.reduce(
        (prev, curr) => {
          prev.functionSelectors.push(foo.interface.getSighash(curr.name));
          return prev;
        },
        {
          facetAddress: foo.address,
          action: 0,
          functionSelectors: ([] as string[]),
        },
      );

      // diamond cut
      await (await ethers.getContractAt('DiamondCutFacet', diamond.address) as DiamondCutFacet)
        .diamondCut([faucet], ethers.constants.AddressZero, '0x');
    });

    it('foo function', async () => {
      const f = await ethers.getContractAt('Foo', diamond.address) as Foo;
      expect(await f.get()).eq(0);
      await f.setFoo(33);
      expect(await f.get()).eq(33);
    });
  });
});
