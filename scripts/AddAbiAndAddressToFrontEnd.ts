import { ethers, network } from "hardhat";
import fs from "fs";
import "dotenv/config";

const exportProperties = async (contractAddresses: string[]) => {
  await exportAbis(contractAddresses);
  await exportAddresses(contractAddresses);
};
const TOKEN_ADDRESS = "/home/bekim/Documents/Project/Apps/Web3/GNFT_GeneralPage/src/constants/Token/TokenAddress.json";
const GNFT_ADDRESS = "/home/bekim/Documents/Project/Apps/Web3/GNFT_GeneralPage/src/constants/BasicGNFT/BasicGNFTAddress.json";
const GAME_ADDRESS = "/home/bekim/Documents/Project/Apps/Web3/GNFT_GeneralPage/src/constants/Game/GameAddress.json";
const TOKEN_ABI = "/home/bekim/Documents/Project/Apps/Web3/GNFT_GeneralPage/src/constants/Token/TokenABI.json";
const GNFT_ABI = "/home/bekim/Documents/Project/Apps/Web3/GNFT_GeneralPage/src/constants/BasicGNFT/BasicGNFTABI.json";
const GAME_ABI = "/home/bekim/Documents/Project/Apps/Web3/GNFT_GeneralPage/src/constants/Game/GameABI.json";

const Contracts = ["Token", "BasicGNFT", "Games"];
const FrontEndAddressPaths = [
  TOKEN_ADDRESS,
  GNFT_ADDRESS,
  GAME_ADDRESS
];
const FrontEndAbiPaths = [
  TOKEN_ABI,
  GNFT_ABI,
  GAME_ABI
];
const exportAbis = async (contractAddresses: string[]) => {
  for (let i = 0; i < Contracts.length; i++) {
    const contract = await ethers.getContractAt(
      Contracts[i],
      contractAddresses[i]
    );
    fs.writeFileSync(
      FrontEndAbiPaths[i],
      contract.interface.format(ethers.utils.FormatTypes.json).toString()
    );
  }
};

const exportAddresses = async (contractAddresses: string[]) => {
  for (let i = 0; i < Contracts.length; i++) {
    const lottery = await ethers.getContractAt(
      Contracts[i],
      contractAddresses[i]
    );

    const chainId = network.config.chainId?.toString();
    const currentAddresses = JSON.parse(
      fs.readFileSync(FrontEndAddressPaths[i], "utf8")
    );
    if (chainId! in currentAddresses) {
      if (!currentAddresses[chainId!].includes(lottery.address)) {
        currentAddresses[chainId!].push(lottery.address);
      }
    } else {
      currentAddresses[chainId!] = [lottery.address];
    }
    fs.writeFileSync(FrontEndAddressPaths[i], JSON.stringify(currentAddresses));
  }
};

export default exportProperties;
