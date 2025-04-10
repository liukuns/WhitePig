<template>
  <div class="app-container">
    <!-- 顶部导航栏 -->
    <header class="app-header">
      <div class="logo-container">
        <h1 class="logo-text">White Pig</h1>
      </div>
      <button class="connect-wallet-btn" @click="connectWallet">
        {{ walletConnected ? formattedWalletAddress : '连接钱包' }}
      </button>
    </header>

    <!-- 主体内容 -->
    <div class="app-body">
      <div id="guide">
        <button class="guide-button" @click="switchModule('rentalMarket')">
          <i class="icon icon-rental-market"></i> 租房市场
        </button>
        <button class="guide-button" @click="switchModule('userInfo')">
          <i class="icon icon-user-info"></i> 我的信息
        </button>
        <button class="guide-button" @click="switchModule('userProperties')">
          <i class="icon icon-user-properties"></i>我的交易
        </button>
        <button class="guide-button" @click="switchModule('daoManagement')">
          <i class="icon icon-dao-management"></i> DAO
        </button>
        <button class="guide-button" @click="switchModule('learnMore')">
          <i class="icon icon-learn-more"></i> 了解更多
        </button>
      </div>

      <div class="module-container">
        <component
          :is="activeModuleComponent"
          v-if="activeModuleComponent"
          :transaction="selectedTransaction"
          @view-transaction="viewTransactionDetails"
          @go-back="switchModule('userInfo')"
          :walletAddress="walletAddress"
          :userInformationContract="userInformationContract"
          :rentRequestContract="rentRequestContract"
          :rentDAOContract="rentDAOContract"
          :propertyManagementContract="propertyManagementContract"
          :propertyMarketContract="propertyMarketContract"
          :usdtContract="usdtContract"
        ></component>
      </div>
    </div>
  </div>
</template>

<script>
import UserInfo from './components/UserInfo.vue';
import DaoManagement from './components/DaoManagement.vue';
import RentalMarket from './components/RentalMarket.vue';
import LearnMore from './components/LearnMore.vue';
import TransactionDetails from './components/TransactionDetails.vue';
import UserProperties from './components/UserProperties.vue';
import { ethers } from 'ethers';
import { userInformationABI } from './assets/abi/userInformationABI.js';
import { rentRequestABI } from './assets/abi/rentRequestABI.js';
import { rentDAOABI } from './assets/abi/rentDAOABI.js';
import { propertyManagementABI } from './assets/abi/propertyManagementABI.js';
import { propertyMarketABI } from './assets/abi/propertyMarketABI.js';
import { usdtABI } from './assets/abi/usdtABI.js';

export default {
  data() {
    return {
      walletConnected: false,
      walletAddress: '',
      activeModule: 'rentalMarket', // 默认显示租房市场
      selectedTransaction: null, // 存储选中的交易详情
      userInformationContract: null,
      rentRequestContract: null,
      rentDAOContract: null,
      propertyManagementContract: null,
      propertyMarketContract: null,
      usdtContract: null, // 添加 USDT 合约实例
      currentUserAddress: '' // 当前用户地址
    };
  },
  methods: {
    async connectWallet() {
      if (typeof window.ethereum !== 'undefined') {
        try {
          // 请求用户授权连接钱包
          const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
          this.walletAddress = accounts[0]; // 获取用户的第一个钱包地址
          this.walletConnected = true;
          alert(`钱包已连接: ${this.walletAddress}`);
        } catch (error) {
          console.error('连接钱包失败:', error);
          alert('连接钱包失败，请重试');
        }
      } else {
        alert('未检测到 MetaMask，请安装 MetaMask 插件');
      }
    },
    switchModule(moduleId) {
      this.activeModule = moduleId;
      this.selectedTransaction = null; // 切换模块时清空选中的交易详情
    },
    viewTransactionDetails(transaction) {
      this.selectedTransaction = transaction; // 设置选中的交易详情
      this.activeModule = 'transactionDetails'; // 切换到交易详情模块
    },
    handleAccountsChanged(accounts) {
      if (accounts.length === 0) {
        // 用户断开连接
        this.walletConnected = false;
        this.walletAddress = '';
        alert('钱包已断开连接');
      } else {
        // 更新钱包地址
        this.walletAddress = accounts[0];
      }
    },
    async getCurrentUserAddress() {
      // 获取当前用户地址的逻辑
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      return accounts[0];
    }
  },
  async created() {
    if (typeof window.ethereum === 'undefined') {
      alert('请安装 MetaMask 或其他以太坊钱包插件');
      return;
    }

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();

    try {
      // 获取钱包地址
      const accounts = await provider.send('eth_requestAccounts', []);
      this.walletAddress = accounts[0];

      // 初始化 userInformation 合约实例
      const userInformationAddress = '0x16F93e3D98B4424f38fB8fCCf78d603f7E49dDCc'; // 替换为实际地址
      this.userInformationContract = new ethers.Contract(userInformationAddress, userInformationABI, signer);

      // 初始化 rentRequest 合约实例
      const rentRequestAddress = '0x1f8100B9d7a1BC8AA5AB3C499AfDd41781455aBe'; // 替换为实际地址
      this.rentRequestContract = new ethers.Contract(rentRequestAddress, rentRequestABI, signer);

      // 初始化 rentDAO 合约实例
      const rentDAOAddress = '0x56A3bD54FfFc4A9Adbf9c65784b5B2CC6CAf565E'; // 替换为实际地址
      this.rentDAOContract = new ethers.Contract(rentDAOAddress, rentDAOABI, signer);

      // 初始化 propertyManagement 合约实例
      const propertyManagementAddress = '0xD25672338b19552c706fb94Df230503bA74E8F50'; // 替换为实际地址
      this.propertyManagementContract = new ethers.Contract(propertyManagementAddress, propertyManagementABI, signer);

      // 初始化 propertyMarket 合约实例
      const propertyMarketAddress = '0x5Ff0D772CB42e7aC61724bc6461B7e6440e40F56'; // 替换为实际地址
      this.propertyMarketContract = new ethers.Contract(propertyMarketAddress, propertyMarketABI, signer);
      console.log(this.propertyMarketContract);

      // 初始化 USDT 合约实例
      const usdtAddress = '0x6b7A9D8719794c4117fea85dA10597Fa5ba99F01'; // 替换为实际 USDT 合约地址
      this.usdtContract = new ethers.Contract(usdtAddress, usdtABI, signer);
      console.log(this.usdtContract);

      // 初始化当前用户地址
      this.currentUserAddress = await this.getCurrentUserAddress();
      console.log('当前用户地址:', this.currentUserAddress);

      console.log('合约实例已初始化');
    } catch (error) {
      console.error('初始化合约实例失败:', error);
      alert('初始化失败，请检查您的以太坊环境');
    }
  },
  mounted() {
    if (typeof window.ethereum !== 'undefined') {
      // 监听账户变化
      window.ethereum.on('accountsChanged', this.handleAccountsChanged);

      // 检查当前连接状态
      window.ethereum.request({ method: 'eth_accounts' }).then(accounts => {
        if (accounts.length > 0) {
          this.walletAddress = accounts[0];
          this.walletConnected = true;
        }
      });
    }
  },
  beforeDestroy() {
    if (typeof window.ethereum !== 'undefined') {
      // 移除事件监听器
      window.ethereum.removeListener('accountsChanged', this.handleAccountsChanged);
    }
  },
  components: {
    UserInfo,
    DaoManagement,
    RentalMarket,
    LearnMore,
    TransactionDetails,
    UserProperties
  },
  computed: {
    activeModuleComponent() {
      if (this.activeModule === 'transactionDetails') {
        return 'TransactionDetails';
      }
      switch (this.activeModule) {
        case 'rentalMarket':
          return 'RentalMarket';
        case 'userInfo':
          return 'UserInfo';
        case 'daoManagement':
          return 'DaoManagement';
        case 'learnMore':
          return 'LearnMore';
        case 'userProperties':
          return 'UserProperties';
        default:
          return null;
      }
    },
    formattedWalletAddress() {
      if (this.walletAddress) {
        return `${this.walletAddress.slice(0, 4)}...${this.walletAddress.slice(-4)}`;
      }
      return '';
    }
  }
};
</script>

<style>
.app-container {
  width: 97%;
  font-family: 'Cursive', 'Arial', sans-serif; /* 添加飘逸字体 */
}

/* head */
.app-header {
  width: 100%;
  height: 5%;
  border: none; /* 移除边框 */
  padding: 20px;
  border-radius: 10px;
  border: #000000 solid 4px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 添加阴影 */
  transition: transform 0.2s, box-shadow 0.2s; /* 添加动画效果 */
}

.logo-container {
  background-color: transparent; /* 透明背景 */
  width: 70%;
  height: 100px;
  margin-left: 5%;
  display: flex;
  align-items: center;
}

.logo-text {
  font-size: 50px;
  color: #423f3f; /* 修改为白色字体 */
  margin-left: 10px;
  font-family: 'Cursive', 'Arial', sans-serif; /* 添加飘逸字体 */
  font-style: italic; /* 修改为斜体 */
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5); /* 添加文字阴影 */
}

.connect-wallet-btn {
  width: 10%;
  height: 100%;
  margin-right: 5%;
  color: #000000;
  border: none;
  padding: 10px 20px;
  border-radius: 10px; /* 圆角 */
  font-family: 'Cursive', 'Arial', sans-serif; /* 添加飘逸字体 */
  font-size: 16px;
  cursor: pointer;
  box-shadow: 0 10px 10px rgba(0, 0, 0, 0.1); /* 添加阴影 */
  transition: transform 0.2s, box-shadow 0.2s; /* 添加动画效果 */
  display: flex;
  align-items: center;
  justify-content: center;
}

.connect-wallet-btn:hover {
  transform: translateY(-3px); /* 悬停时上移 */
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2), 0 6px 10px rgba(0, 0, 0, 0.15); /* 增强阴影效果 */
}

/* body */
.app-body {
  width:100%; /* 修改为与app-body一致 */
  height: 780px;
  background-color: #ffffff;
  border: #181818 solid 4px;
  padding: 20px;
  margin-top: 10px;
  border-radius: 10px;
  display: flex; /* 修改为flex布局 */
  align-items: center; /* 垂直居中 */
  justify-content: space-between; /* 两端对齐 */
}
#guide {
  width: 16%;
  height: 100%;
  color: #ffffff;
  border: #181818 solid 4px;
  border-radius: 10px;
  justify-content: space-between;
  margin-top: 0px;
  font-family: 'Cursive', 'Arial', sans-serif; /* 添加飘逸字体 */
}
.guide-button {
  width: 90%;
  height: 50px;
  color: #000000;
  border: none;
  margin: 10px;
  margin-bottom: 20px;
  border-radius: 10px; /* 圆角 */
  font-size: 18px;
  cursor: pointer;
  font-family: 'Cursive', 'Arial', sans-serif; /* 添加飘逸字体 */
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 10px; /* 图标与文字的间距 */
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 添加阴影 */
  transition: transform 0.2s, box-shadow 0.2s; /* 添加动画效果 */
  letter-spacing: 17px; /* 增加文字间距 */
}

.guide-button:hover {
  transform: translateY(-3px); /* 悬停时上移 */
  box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15); /* 悬停时阴影增强 */
}

.icon {
  width: 24px;
  height: 24px;
  display: inline-block;
  background-size: cover;
}

.icon-rental-market {
  background-image: url('/assets/icons/rental-market.png'); /* 替换为实际图标路径 */
}

.icon-user-info {
  background-image: url('/assets/icons/user-info.png'); /* 替换为实际图标路径 */
}

.icon-user-properties {
  background-image: url('/assets/icons/user-properties.png'); /* 替换为实际图标路径 */
}

.icon-dao-management {
  background-image: url('/assets/icons/dao-management.png'); /* 替换为实际图标路径 */
}

.icon-learn-more {
  background-image: url('/assets/icons/learn-more.png'); /* 替换为实际图标路径 */
}

.module-container {
  border: #181818 solid 4px;
  width: 80%;
  height: 95%;
  background-color: #ffffff;
  padding: 20px;
  border-radius: 10px;
  margin-right: 0px;
  margin-left: 20px;
  font-family: 'Cursive', 'Arial', sans-serif; /* 添加飘逸字体 */
  overflow-y: auto; /* 添加垂直滚动条 */
  scrollbar-width: none; /* 隐藏 Firefox 滚动条 */
}

.module-container::-webkit-scrollbar {
  display: none; /* 隐藏 Chrome 和 Safari 滚动条 */
}
</style>