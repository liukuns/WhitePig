const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PropertyMarket Contract", function () {
  let usdt, userInformation, propertyManagement, rentDAO, propertyMarket;
  let owner, user1, user2;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    // 部署 USDT 合约
    const USDT = await ethers.getContractFactory("usdt");
    usdt = await USDT.deploy("Tether USD", "USDT");
    await usdt.deployed();

    // 部署 UserInformation 合约
    const UserInformation = await ethers.getContractFactory("userInformation");
    userInformation = await UserInformation.deploy();
    await userInformation.deployed();

    // 部署 PropertyManagement 合约
    const PropertyManagement = await ethers.getContractFactory("propertyManagement");
    propertyManagement = await PropertyManagement.deploy();
    await propertyManagement.deployed();

    // 部署 RentDAO 合约
    const RentDAO = await ethers.getContractFactory("rentDAO");
    rentDAO = await RentDAO.deploy(userInformation.address, usdt.address);
    await rentDAO.deployed();

    // 部署 PropertyMarket 合约
    const PropertyMarket = await ethers.getContractFactory("propertyMarket");
    propertyMarket = await PropertyMarket.deploy(
      propertyManagement.address,
      usdt.address,
      userInformation.address,
      rentDAO.address
    );
    await propertyMarket.deployed();
  });

  it("should allow a user to add a property to the market", async function () {
    // 模拟用户绑定身份
    await userInformation.verify("123456789", "1234567890");

    // 添加房源
    const tx = await propertyMarket.connect(owner).addPropertyMarket(
      ethers.utils.parseEther("1"), // 月租金
      "Two-bedroom apartment",      // 房屋类型
      "A beautiful apartment",      // 描述
      "123 Main St"                 // 地址
    );
    await tx.wait();

    // 验证房源是否添加成功
    const properties = await propertyMarket.getMyProperty();
    expect(properties.length).to.equal(1);
    expect(properties[0].location).to.equal("123 Main St");
  });

  it("should allow a user to rent a property", async function () {
    // 模拟用户绑定身份
    await userInformation.verify("123456789", "1234567890");

    // 添加房源
    await propertyMarket.connect(owner).addPropertyMarket(
      ethers.utils.parseEther("1"), // 月租金
      "Two-bedroom apartment",      // 房屋类型
      "A beautiful apartment",      // 描述
      "123 Main St"                 // 地址
    );

    // 模拟租客充值 USDT
    await usdt.mint(user1.address, ethers.utils.parseEther("10"));
    await usdt.connect(user1).approve(propertyMarket.address, ethers.utils.parseEther("10"));

    // 租房
    const tx = await propertyMarket.connect(user1).rent(
      1,                            // 房屋 ID
      2,                            // 租赁月数
      "Sample Rent Contract"        // 租赁合同
    );
    await tx.wait();

    // 验证房屋状态
    const property = await propertyManagement.getProperty(1);
    expect(property.isAvailable).to.equal(false);
  });

  it("should allow a landlord to chargeback deposit", async function () {
    // 模拟用户绑定身份
    await userInformation.verify("123456789", "1234567890");

    // 添加房源
    await propertyMarket.connect(owner).addPropertyMarket(
      ethers.utils.parseEther("1"), // 月租金
      "Two-bedroom apartment",      // 房屋类型
      "A beautiful apartment",      // 描述
      "123 Main St"                 // 地址
    );

    // 模拟租客充值 USDT
    await usdt.mint(user1.address, ethers.utils.parseEther("10"));
    await usdt.connect(user1).approve(propertyMarket.address, ethers.utils.parseEther("10"));

    // 租房
    await propertyMarket.connect(user1).rent(
      1,                            // 房屋 ID
      2,                            // 租赁月数
      "Sample Rent Contract"        // 租赁合同
    );

    // 房东退还押金
    const tx = await propertyMarket.connect(owner).chargeback(1);
    await tx.wait();

    // 验证押金状态
    const isPawned = await rentDAO.isPawned(1);
    expect(isPawned).to.equal(false);
  });
});
