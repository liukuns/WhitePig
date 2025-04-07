<template>
  <div class="app-container">
    <!-- 顶部导航栏 -->
    <header class="app-header">
      <div class="logo-container">
        <h1 class="logo-text">White Pig</h1>
      </div>
      <button class="connect-wallet-btn" @click="connectWallet">
        {{ walletConnected ? '已连接' : '连接钱包' }}
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
    connectWallet() {
      // 模拟连接钱包
      this.walletConnected = true;
      this.walletAddress = '0x12...3456';
      alert('钱包已连接');
    },
    switchModule(moduleId) {
      this.activeModule = moduleId;
      this.selectedTransaction = null; // 切换模块时清空选中的交易详情
    },
    viewTransactionDetails(transaction) {
      this.selectedTransaction = transaction; // 设置选中的交易详情
      this.activeModule = 'transactionDetails'; // 切换到交易详情模块
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
  height: 90%;
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