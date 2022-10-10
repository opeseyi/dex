import { DeployFunction } from 'hardhat-deploy/types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
// const ethers = require('hardhat');

const deployDex: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    const { deployments, getNamedAccounts, network, ethers } = hre;
    const { log, deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    // TOKENS
    console.log('Deloying Tokens');
    const dai = await deploy('DAI', {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 1,
    });

    const usdc = await deploy('USDC', {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 1,
    });

    const usdt = await deploy('USDT', {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 1,
    });
    console.log('Deployed Tokens');

    const args: any[] = [[dai.address, usdc.address, usdt.address]];

    log('-------DEPLOYING DEX------');
    const dex = await deploy('DexV1', {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: 1,
    });
    log('-------DEPLOYED DEX-------');
};

export default deployDex;
deployDex.tags = ['all'];
