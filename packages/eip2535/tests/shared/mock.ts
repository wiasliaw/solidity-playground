import { ethers } from 'hardhat';

import { Fixture } from 'ethereum-waffle';
import {
  MockDiamondCutFacet,
  MockOwnableFacet,
  Foo,
  Bar,
} from '../../dist/types';

interface MockFixture {
  diamondCut: MockDiamondCutFacet;
  ownable: MockOwnableFacet;
  foo: Foo,
  bar: Bar,
}

export const mockFixture: Fixture<MockFixture> = async function (): Promise<MockFixture> {
  const [deployer] = await ethers.getSigners();

  const diamondCut = await (await ethers.getContractFactory('MockDiamondCutFacet'))
    .deploy(deployer.address) as MockDiamondCutFacet;
  await diamondCut.deployed();

  const ownable = await (await ethers.getContractFactory('MockOwnableFacet'))
    .deploy(deployer.address) as MockOwnableFacet;
  await ownable.deployed();

  const foo = await (await ethers.getContractFactory('Foo')).deploy() as Foo;
  await foo.deployed();

  const bar = await (await ethers.getContractFactory('Bar')).deploy() as Bar;
  await bar.deployed();

  return {
    diamondCut,
    ownable,
    foo,
    bar,
  };
};
