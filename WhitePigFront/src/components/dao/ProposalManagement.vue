<template>
  <div class="proposal-management">
    <div class="back-button-container">
      <button class="back-button" @click="$emit('goBack')">返回</button>
    </div>
    <p>发起提案、提案投票以及查看提案列表。</p>

    <div class="actions">
      <button @click="createProposal">发起提案</button>
      <button @click="voteProposal">提案投票</button>
      <button @click="viewProposals">查看提案列表</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ProposalManagement',
  methods: {
    createProposal() {
      console.log('进入发起提案功能');
    },
    voteProposal() {
      console.log('进入提案投票功能');
    },
    viewProposals() {
      console.log('查看提案列表');
    }
  }
};
</script>

<style scoped>
.proposal-management {
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
  position: relative;
}

.back-button,
.actions button {
  padding: 10px 20px; /* 统一按钮样式 */
  background-color: #f0f0f0; /* 浅灰色背景 */
  color: #000; /* 黑色字体 */
  border: none;
  border-radius: 4px;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* 柔和阴影 */
  transition: all 0.3s ease;
}

.back-button:hover,
.actions button:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* 鼠标悬停时更深的阴影 */
  transform: translateY(-1px); /* 轻微上移 */
}

.back-button {
  display: inline-block; /* 确保按钮正常布局 */
  position: relative; /* 确保布局正常 */
  z-index: 1; /* 提升层级，避免与其他元素重叠 */
}

.actions button {
  margin: 5px;
}

.actions button:hover {
  opacity: 0.9;
}

.back-button-container {
  margin-bottom: 20px; /* 添加与内容的间距 */
  text-align: left; /* 按钮靠左对齐 */
  display: block; /* 确保按钮单独占一行 */
}
</style>
