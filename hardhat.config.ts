import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";
const PRIVATE_KEY = process.env.WALLET_PRIVATE_KEY!;
const OPTIMISM_RPC_URL = process.env.PROVIDER_URL;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const COINTMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY;
const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY;
const Goerli_RPC =  process.env.GOERLI_RPC;
const config = {
  solidity: "0.8.7",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    optimism: {
      chainId: 420,
      url: OPTIMISM_RPC_URL,
      accounts: [PRIVATE_KEY],
    },
    goerli: {
      chainId: 5,
      url: Goerli_RPC,
      accounts: [GOERLI_PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
  gasReporter: {
    enabled: false,
    outputFile: "gas-reporter.txt",
    noColors: true,
    currency: "USD",
    coinmarketcap: COINTMARKETCAP_API_KEY,
    token: "ETH",
  },
};

export default config;
