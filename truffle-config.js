require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");
const web3 = require("web3");

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 8545, // Standard Ethereum port (default: none)
      network_id: "*", // Any network (default: none)
      gasPrice: 5000000000,
    },
    binancesmartchain: {
      provider: () =>
        new HDWalletProvider(
          process.env.MAINNET_DEPLOYER_PRIVATE_KEY,
          process.env.MORALIAS_BSC_MAINNET_WSS_URL
        ),
      network_id: 56, // bsc mainnet
      gasPrice: 5000000000,
      skipDryRun: false,
    },
    binancesmartchaintest: {
      provider: () =>
        new HDWalletProvider(
          process.env.TESTNET_DEPLOYER_PRIVATE_KEY,
          process.env.MORALIAS_BSC_TESTNET_WSS_URL
        ),
      network_id: 97, // bsc testnet
      gasPrice: 5000000000,
      skipDryRun: false,
    },
    ethereum: {
      provider: () =>
        new HDWalletProvider(
          process.env.MAINNET_DEPLOYER_PRIVATE_KEY,
          process.env.ETHEREUM_INFURA_WSS_URL
        ),
      network_id: 1, // eth mainnet,
      skipDryRun: false,
    },
    fantom: {
      provider: () =>
        new HDWalletProvider(
          process.env.TESTNET_DEPLOYER_PRIVATE_KEY,
          process.env.MORALIAS_FANTOM_MAINNET_WSS_URL
        ),
      network_id: 250, // fantom mainnet,
      skipDryRun: false,
    },
    goreli: {
      provider: () =>
        new HDWalletProvider(
          process.env.TESTNET_DEPLOYER_PRIVATE_KEY,
          process.env.GORELI_INFURA_WSS_URL
        ),
      network_id: 5, // goreli,
      skipDryRun: false,
    },
    kovan: {
      provider: () =>
        new HDWalletProvider(
          process.env.TESTNET_DEPLOYER_PRIVATE_KEY,
          process.env.KOVAN_INFURA_WSS_URL
        ),
      network_id: 42, // kovan,
      skipDryRun: false,
    },
    mumbai: {
      provider: () =>
        new HDWalletProvider(
          process.env.TESTNET_DEPLOYER_PRIVATE_KEY,
          process.env.MORALIAS_POLYGON_MUMBAI_WSS_URL
        ),
      network_id: 80001, // polygon testnet,
      skipDryRun: false,
    },
    ropsten: {
      provider: () =>
        new HDWalletProvider(
          process.env.TESTNET_DEPLOYER_PRIVATE_KEY,
          process.env.ROPSTEN_INFURA_URL
        ),
      network_id: 3, // ropsten,
      skipDryRun: false,
    },
    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          process.env.TESTNET_DEPLOYER_PRIVATE_KEY,
          process.env.RINKEBY_INFURA_WSS_URL
        ),
      network_id: 4, // rinkeby,
      skipDryRun: false,
    },
    polygon: {
      provider: () =>
        new HDWalletProvider(
          process.env.MAINNET_DEPLOYER_PRIVATE_KEY,
          process.env.POLYGON_INFURA_URL
        ),
      network_id: 137, // polygon mainnet,
      gasPrice: 470000000000,
      skipDryRun: false,
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    timeout: 100000000,
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.3", // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 1000000000,
        },
        evmVersion: "byzantium",
      },
    },
  },
  plugins: ["truffle-contract-size"],
};
