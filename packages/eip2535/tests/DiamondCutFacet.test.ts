import { ethers, waffle } from 'hardhat';
import { expect, use } from 'chai';
import { mockFixture } from './shared';

import { Wallet } from 'ethers';
import { Bar, Foo, MockDiamondCutFacet } from '../dist/types';

use(waffle.solidity);

describe('DiamondCutFacet', () => {
  let user1: Wallet, user2: Wallet;
  let loadFixture: ReturnType<typeof waffle.createFixtureLoader>;

  let diamondCut: MockDiamondCutFacet;
  let foo: Foo;
  let bar: Bar;

  before('create fixture', async () => {
    [user1, user2] = await (ethers as any).getSigners();
    loadFixture = waffle.createFixtureLoader([user1, user2]);
  });

  beforeEach('deploy fixture', async () => {
    ({ diamondCut, foo, bar } = await loadFixture(mockFixture));
  });

  describe('#diamondCut', () => {
    let fooFaucet: any;

    beforeEach(async () => {
      fooFaucet = {
        facetAddress: foo.address,
        action: 0,
        functionSelectors: ['0x6d4ce63c', '0xdc80035d']
      };
    });

    it('success', async () => {
      await expect(diamondCut.diamondCut(
        [fooFaucet],
        ethers.constants.AddressZero,
        '0x',
      )).emit(diamondCut, 'DiamondCut');

      expect(await diamondCut.get('0x6d4ce63c')).eq(foo.address);
      expect(await diamondCut.get('0xdc80035d')).eq(foo.address);
    });

    it('should revert', async () => {
      await expect(diamondCut.connect(user2).diamondCut(
        [fooFaucet],
        ethers.constants.AddressZero,
        '0x',
      )).reverted;
    });
  });

  describe('#_addFunction', () => {
    beforeEach(async () => {
      // add `foo.get` and `foo.setFoo`
      await diamondCut.diamondCut(
        [{
          facetAddress: foo.address,
          action: 0,
          functionSelectors: ['0x6d4ce63c', '0xdc80035d']
        }],
        ethers.constants.AddressZero,
        '0x',
      );
    });

    it('success', async () => {
      // add `bar.setBar`
      await diamondCut.addFunction(bar.address, ['0x352d3fba']);
      expect(await diamondCut.get('0x352d3fba')).eq(bar.address);
    });

    it('should revert', async () => {
      // no selectors
      await expect(diamondCut.addFunction(bar.address, []))
        .revertedWith('LibDiamondCut: No selectors in facet to cut');
      // can't be address(0)
      await expect(diamondCut.addFunction(ethers.constants.AddressZero, ['0x352d3fba']))
        .revertedWith("LibDiamondCut: Add facet can't be address(0)");
      // no code
      await expect(diamondCut.addFunction(
          '0x0000000000000000000000000000000000000001',
          ['0x352d3fba'],
        )).revertedWith('LibDiamondCut: Add facet has no code');
      // add `bar.get`
      await expect(diamondCut.addFunction(bar.address, ['0x6d4ce63c']))
        .revertedWith("LibDiamondCut: Can't add function that already exists");
    });
  });

  describe('#_replaceFunctions', () => {
    beforeEach(async () => {
      // add `foo.get` and `foo.setFoo`
      await diamondCut.diamondCut(
        [{
          facetAddress: foo.address,
          action: 0,
          functionSelectors: ['0x6d4ce63c', '0xdc80035d']
        }],
        ethers.constants.AddressZero,
        '0x',
      );
    });

    it('success', async () => {
      await diamondCut.replaceFunctions(bar.address, ['0x6d4ce63c']);
      expect(await diamondCut.get('0x6d4ce63c')).eq(bar.address);
    });
  });

  describe('#_removeFunctions', () => {
    beforeEach(async () => {
      // add `foo.get` and `foo.setFoo`
      await diamondCut.diamondCut(
        [{
          facetAddress: foo.address,
          action: 0,
          functionSelectors: ['0x6d4ce63c', '0xdc80035d']
        }],
        ethers.constants.AddressZero,
        '0x',
      );
    });

    it('success', async () => {
      await diamondCut.removeFunctions(ethers.constants.AddressZero, ['0x6d4ce63c']);
      await expect(diamondCut.get('0x6d4ce63c')).reverted;
    });
  });
});
