const { ethers } = require("hardhat");

async function main() {
  // 获取部署的 rmb 合约地址
  const usdtAddress = "0x6b7A9D8719794c4117fea85dA10597Fa5ba99F01"; // 替换为实际的rmb合约地址
  const recipient = "0xA189b4EDC44F7343df8232a0615629556a2daf4f"; // 替换为实际的用户地址
  const mintAmount = ethers.utils.parseUnits("100000", 18); // 100,000 个代币，假设代币有 18 位小数

  // 连接到 usdt 合约
  const USDT = await ethers.getContractFactory("usdt");
  const usdt = await USDT.attach(usdtAddress);

  // 调用 mint 方法
  const tx = await usdt.mint(mintAmount);
  await tx.wait();

  console.log(`Minted 100,000 USDT to ${recipient}`);
}

// 运行主函数并捕获错误
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
