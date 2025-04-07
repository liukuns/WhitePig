require('dotenv').config({ path: './.env' }); // 确保加载 .env 文件
require("@nomiclabs/hardhat-ethers"); // 加载 ethers 插件

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    goerli: {
      url: "https://eth-goerli.api.onfinality.io/public",
      accounts: process.env.PRIVATE_KEY1 ? [process.env.PRIVATE_KEY1] : [], // 确保私钥存在
      chainId: 5,
    },
    sepolia: {    // Sepolia 测试网
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [], // 确保私钥存在
      chainId: 11155111,
    },
  },
};
