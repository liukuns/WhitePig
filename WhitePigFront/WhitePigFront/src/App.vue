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
        <button class="guide-button" @click="switchModule('rentalMarket')">租房市场</button>
        <button class="guide-button" @click="switchModule('userInfo')">用户信息</button>
        <button class="guide-button" @click="switchModule('daoManagement')">DAO管理</button>
        <button class="guide-button" @click="switchModule('userProperties')">用户房产</button>
        <button class="guide-button" @click="switchModule('learnMore')">了解更多</button>
      </div>

      <div class="module-container">
        <component
          :is="activeModuleComponent"
          v-if="activeModuleComponent"
          :transaction="selectedTransaction"
          @view-transaction="viewTransactionDetails"
          @go-back="switchModule('userInfo')"
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

export default {
  data() {
    return {
      walletConnected: false,
      walletAddress: '',
      activeModule: 'rentalMarket', // 默认显示租房市场
      selectedTransaction: null // 存储选中的交易详情
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
        alert(`钱包地址已更新: ${this.walletAddress}`);
      }
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
  width: 100%; /* 修改为与app-body一致 */
  height: 5%;
  background-color: #ffffff;
  border: #181818 solid 4px;
  padding: 20px;
  border-radius: 10px;
  display: flex; /* 修改为flex布局 */
  align-items: center; /* 垂直居中 */
  justify-content: space-between; /* 两端对齐 */
}
.logo-container {
  background-color: #ffffff;
  width: 70%;
  height: 100px;
  margin-left: 5%;
  display: flex;
  align-items: center;
}
.logo-text {
  font-size: 50px;
  color: #181818;
  margin-left: 10px;
  font-family: 'Cursive', 'Arial', sans-serif; /* 添加飘逸字体 */
  font-style: italic; /* 修改为斜体 */
}
.connect-wallet-btn {
  width: 10%;
  height: 100%;
  margin-right: 5%;
  background-color: #000000;
  color: #ffffff;
  border: none;
  padding: 10px 20px;
  border-radius: 5px;
  font-family: 'Cursive', 'Arial', sans-serif; /* 添加飘逸字体 */
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
  background-color: #000000;
  color: #ffffff;
  border: none;
  margin:10px;
  border-radius: 5px;
  font-size: 18px;
  cursor: pointer;
  font-family: 'Cursive', 'Arial', sans-serif; /* 添加飘逸字体 */
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