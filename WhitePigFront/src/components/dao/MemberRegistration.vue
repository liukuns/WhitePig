<template>
  <div class="member-registration">
    <div class="back-button-container">
      <button class="back-button" @click="$emit('goBack')">返回</button>
    </div>
    <p>注册新成员并管理成员信息。</p>

    <div class="actions">
      <button @click="registerMember">注册新成员</button>
      <button @click="manageMembers">管理成员信息</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MemberRegistration',
  props: {
    rentDAOContract: { // 接收 rentDAO 合约实例
      type: Object,
      required: true
    }
  },
  methods: {
    async registerMember() {
      try {
        console.log('正在注册为新成员...');
        const tx = await this.rentDAOContract.registerAsMember();
        await tx.wait(); // 等待交易完成
        alert('注册成功！您已成为 DAO 成员。');
      } catch (error) {
        console.error('注册失败:', error);
        alert('注册失败，请稍后重试。');
      }
    },
    manageMembers() {
      console.log('进入管理成员信息功能');
    }
  }
};
</script>

<style scoped>
.member-registration {
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
  position: relative;
}

.back-button-container {
  margin-bottom: 30px; /* 增加与下面内容的间距 */
  text-align: left; /* 按钮靠左对齐 */
  display: block; /* 确保按钮单独占一行 */
}

.back-button {
  padding: 10px 20px; /* 墛大按钮尺寸 */
  display: inline-block; /* 确保按钮正常布局 */
  background-color: #f0f0f0; /* 浅灰色背景 */
  color: #000; /* 黑色字体 */
  border: none;
  border-radius: 4px;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* 柔和阴影 */
  transition: all 0.3s ease;
}

.back-button:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* 鼠标悬停时更深的阴影 */
  transform: translateY(-1px); /* 轻微上移 */
}

.actions button {
  margin: 5px;
  padding: 10px 20px;
  background-color: #f0f0f0; /* 浅灰色背景 */
  color: #000; /* 黑色字体 */
  border: none;
  border-radius: 4px;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* 柔和阴影 */
  transition: all 0.3s ease;
}

.actions button:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* 鼠标悬停时更深的阴影 */
  transform: translateY(-1px); /* 轻微上移 */
}
</style>
