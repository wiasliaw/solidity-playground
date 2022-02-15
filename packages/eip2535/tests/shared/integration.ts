import { ethers } from 'hardhat';

import { Fixture } from 'ethereum-waffle';
import {
  Diamond,
} from '../../dist/types';

interface IntegrationFixture {
  diamond: Diamond;
}

export const integrationFixture: Fixture<IntegrationFixture> = async function (): Promise<IntegrationFixture> {
  const [deployer] = await ethers.getSigners();

  // deployment
  const diamond = await (await ethers.getContractFactory('Diamond'))
    .deploy(deployer.address) as Diamond;
  await diamond.deployed();

  return {
    diamond,
  };
};
