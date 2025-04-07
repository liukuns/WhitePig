const { ethers } = require("hardhat");

async function main() {
  // 部署 usdt 合约
  const USDT = await ethers.getContractFactory("usdt");
  const usdt = await USDT.deploy("Tether USD", "USDT");
  // 传入参数：名称、符号
  await usdt.deployed();
  console.log("usdt deployed to:", usdt.address);

  // 部署 userInformation 合约
  const UserInformation = await ethers.getContractFactory("userInformation");
  const userInformation = await UserInformation.deploy();
  await userInformation.deployed();
  console.log("userInformation deployed to:", userInformation.address);

  // 部署 propertyManagement 合约
  const PropertyManagement = await ethers.getContractFactory("propertyManagement");
  const propertyManagement = await PropertyManagement.deploy();
  await propertyManagement.deployed();
  console.log("propertyManagement deployed to:", propertyManagement.address);

  // 部署 propertyRentERC20 合约
  const PropertyRentERC20 = await ethers.getContractFactory("propertyRentERC20");
  const propertyRentERC20 = await PropertyRentERC20.deploy("PropertyRentERC20", "PRE20");
  // 传入参数：名称和符号
  await propertyRentERC20.deployed();
  console.log("propertyRentERC20 deployed to:", propertyRentERC20.address);

  // 部署 rentDAO 合约
  const RentDAO = await ethers.getContractFactory("rentDAO");
  const rentDAO = await RentDAO.deploy(
    userInformation.address,    // _user
    usdt.address,               // _usdt
  );
  await rentDAO.deployed();
  console.log("rentDAO deployed to:", rentDAO.address);

  // 部署 propertyMarket 合约，传入 usdt 和 rentDAO 合约地址作为参数
  const PropertyMarket = await ethers.getContractFactory("propertyMarket");
  const propertyMarket = await PropertyMarket.deploy(
    propertyManagement.address, // _pm
    usdt.address,               // _usdt
    userInformation.address,    // _user
    rentDAO.address             // _dao
  );
  await propertyMarket.deployed();
  console.log("propertyMarket deployed to:", propertyMarket.address);
}

// 运行主函数并捕获错误
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
