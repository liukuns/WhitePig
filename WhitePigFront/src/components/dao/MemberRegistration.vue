<template>
  <div class="member-registration">
    <button class="back-button" @click="$emit('goBack')">返回</button>
    <h2>DAO成员注册</h2>
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

.back-button {
  position: absolute;
  top: 10px;
  left: 10px;
  padding: 5px 10px;
  background-color: #000;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.back-button:hover {
  opacity: 0.9;
}

.actions button {
  margin: 5px;
  padding: 10px 20px;
  background-color: #000;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.actions button:hover {
  opacity: 0.9;
}
</style>
