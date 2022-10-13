import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { assert, expect } from "chai";
import { BigNumber } from "ethers";
import { deployments, ethers, getNamedAccounts, network } from "hardhat";
import { developmentChains } from "../helper-hardhat.config";
import { DexV1, DAI, USDC, USDT } from "../typechain-types";

const AMOUNT = ethers.utils.parseEther("1");
!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Dex Test", () => {
          let accounts: SignerWithAddress[];
          let dex: DexV1;
          let usdc: USDC;
          let dai: DAI;
          let usdt: USDT;
          beforeEach(async () => {
              //   deployer = (await getNamedAccounts()).deployer;
              accounts = await ethers.getSigners();
              await deployments.fixture(["all"]);
              dex = await ethers.getContract("DexV1");
              usdc = await ethers.getContract("USDC");
              dai = await ethers.getContract("DAI");
              usdt = await ethers.getContract("USDT");
          });
          describe("Constructor", function () {
              it("Initialized the constructor", async () => {
                  const args = [dai.address, usdc.address, usdt.address];
                  console.log(args);
                  const token1 = await dex.tokens(0);
                  const token2 = await dex.tokens(1);
                  const token3 = await dex.tokens(2);

                  assert.equal(args[0], token1);
                  assert.equal(args[1], token2);
                  assert.equal(args[2], token3);

                  //   assert.equal(await dex.tokens.length, args.length);
              });
          });
          describe("Swap Token", () => {
              it("Checks both Tokens Address are Valid ", async () => {
                  const zeroAddress = ethers.constants.AddressZero;

                  expect(dai.address != zeroAddress);
                  expect(usdc.address != zeroAddress);
                  expect(
                      dex.swapTokenAtoTokenB(zeroAddress, usdc.address, AMOUNT)
                  ).to.be.revertedWith("Swap: Invalid token A address");
              });
              it("Checks Your Balance and if it > 0", async () => {
                  const AMOUNT = ethers.utils.parseEther("1");
                  const amount = ethers.utils.parseEther("0");

                  expect(AMOUNT > amount);
                  expect(
                      dex.swapTokenAtoTokenB(dai.address, usdc.address, amount)
                  ).to.be.revertedWith("Swap: Amount is invalid or too low");
                  expect(
                      dex.swapTokenAtoTokenB(dai.address, usdc.address, AMOUNT)
                  ).to.not.be.revertedWith("Swap: Amount is invalid or too low");
              });
              it("It get the token amount to be tansferred back", async () => {});
              it('Transfer the "token amount"', async () => {
                  // TRansfer usdc to dex
                  const trannsferUsdcToDex = await usdc.transfer(dex.address, 100);
                  const trannsferDaiToDex = await dai.transfer(dex.address, 100);
                  // check the initial token balance of the contract(usdc/dai) and sender(dai)
                  //   sender
                  const senderInitialDaiBalance = await dai.balanceOf(accounts[0].address);
                  const senderInitUsdcBalance = await usdc.balanceOf(accounts[0].address);
                  console.log(`         Sender Initial USDC ${senderInitUsdcBalance}`);
                  console.log(`         Sender Initial DAI ${senderInitialDaiBalance}`);

                  // dex
                  const dexInitialDaiBalance = await dai.balanceOf(dex.address);
                  const dexInitialUsdcBalance = await usdc.balanceOf(dex.address);
                  console.log(`         dex Initial USDC ${dexInitialUsdcBalance}`);
                  console.log(`         dex Initial DAI ${dexInitialDaiBalance}`);

                  const approved = await usdc.approve(dex.address, 100);
                  const allowance = await usdc.allowance(accounts[0].address, dex.address);
                  //   const allowances = await dex.getAllowance(usdt.address);
                  console.log(`         Allowance ${allowance}`);
                  const usdcContractBalance: any = await usdc.balanceOf(dex.address);
                  console.log("         Dex balance usdc " + usdcContractBalance);
                  const daiContractBalance: any = await dai.balanceOf(dex.address);
                  console.log("         Dex balance dai " + daiContractBalance);
                  const operationSwap = await dex.swapTokenAtoTokenB(
                      usdc.address,
                      dai.address,
                      usdcContractBalance - 10
                  );

                  //   sender
                  const senderFinalDaiBalance = await dai.balanceOf(accounts[0].address);
                  const senderFinalUsdcBalance = await usdc.balanceOf(accounts[0].address);
                  console.log(`         Sender Final USDC ${senderFinalUsdcBalance}`);
                  console.log(`         Sender Final DAI ${senderFinalDaiBalance}`);

                  // dex
                  const dexFinalDaiBalance = await dai.balanceOf(dex.address);
                  const dexFinalUsdcBalance = await usdc.balanceOf(dex.address);
                  console.log(`         dex Final USDC ${dexFinalUsdcBalance}`);
                  console.log(`         dex Final DAI ${dexFinalDaiBalance}`);

                  //   TESTING
                  // Sender
                  expect(senderInitUsdcBalance < senderFinalUsdcBalance);
                  expect(senderInitialDaiBalance > senderFinalDaiBalance);

                  //   Dex
                  expect(dexInitialDaiBalance < dexFinalDaiBalance);
                  expect(dexInitialUsdcBalance > dexFinalUsdcBalance);
              });
          });
      });
