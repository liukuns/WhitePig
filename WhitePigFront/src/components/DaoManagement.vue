<template>
  <div class="dao-management">
    <div class="header" v-if="currentView === 'main'">
      <h2>DAO管理</h2>
      <p>管理您的去中心化自治组织</p>
    </div>

    <div class="content" v-if="currentView === 'main'">
      <!-- 纠纷管理 -->
      <div class="card">
        <h3>纠纷管理</h3>
        <p>处理纠纷投票、纠纷执行以及查看纠纷列表。</p>
        <button @click="currentView = 'DisputeManagement'">管理纠纷</button>
      </div>

      <!-- 内部提案管理 -->
      <div class="card">
        <h3>内部提案管理</h3>
        <p>发起提案、提案投票以及查看提案列表。</p>
        <button @click="currentView = 'ProposalManagement'">管理提案</button>
      </div>

      <!-- DAO成员注册 -->
      <div class="card">
        <h3>DAO成员注册</h3>
        <p>注册新成员并管理成员信息。</p>
        <button @click="currentView = 'MemberRegistration'">注册成员</button>
      </div>
    </div>

    <!-- 动态加载组件 -->
    <component :is="currentView" v-else @goBack="currentView = 'main'" :rentDAOContract = "rentDAOContract" />
  </div>
</template>

<script>
import DisputeManagement from './dao/DisputeManagement.vue';
import ProposalManagement from './dao/ProposalManagement.vue';
import MemberRegistration from './dao/MemberRegistration.vue';

export default {
  name: 'DaoManagement',
  props: {
    rentDAOContract: { // 新增合约实例作为 prop
      type: Object,
      required: true
    }
  },
  components: {
    DisputeManagement,
    ProposalManagement,
    MemberRegistration
  },
  data() {
    return {
      currentView: 'main' // 默认显示主界面
    };
  }
};
</script>

<style scoped>
.dao-management {
  font-family: 'Cursive', 'Arial', sans-serif;
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.header {
  text-align: center;
  margin-bottom: 20px;
}

.header h2 {
  font-size: 28px;
  color: #333;
}

.header p {
  font-size: 16px;
  color: #666;
}

.content {
  display: flex;
  justify-content: space-between;
  gap: 20px;
}

.card {
  flex: 1;
  background-color: #ffffff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  text-align: center;
}

.card h3 {
  font-size: 20px;
  color: #333;
  margin-bottom: 10px;
}

.card p {
  font-size: 14px;
  color: #666;
  margin-bottom: 20px;
}

.card button {
  padding: 10px 20px;
  background-color: #000; /* 修改为黑色背景 */
  color: #fff; /* 修改为白色文字 */
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.card button:hover {
  opacity: 0.9; /* 鼠标悬停时稍微变暗 */
}
</style>
