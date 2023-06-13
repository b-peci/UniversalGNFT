import { ethers } from "hardhat";
import exportProperties from "./AddAbiAndAddressToFrontEnd";
import "dotenv/config";

const main = async () => {
  const BasicGNFT = await ethers.getContractFactory("BasicGNFT");
  const basicToken = await BasicGNFT.deploy();
  await basicToken.deployed();
  console.log(`BasicGNFT contract deployed to ${basicToken.address}`);
  const tokenContract = await ethers.getContractFactory("Token");
  const tokenContractDeployment = await tokenContract.deploy(
    basicToken.address
  );
  await tokenContractDeployment.deployed();
  console.log("Token deployed at " + tokenContractDeployment.address);
  await basicToken.setTokenContractAddress(tokenContractDeployment.address);
  const gameContract = await ethers.getContractFactory("Games");
  const gameContractDeployed = await gameContract.deploy();
  await gameContractDeployed.deployed();
    console.log([tokenContractDeployment.address, basicToken.address, gameContractDeployed.address])
  exportProperties([tokenContractDeployment.address, basicToken.address, gameContractDeployed.address]);
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
