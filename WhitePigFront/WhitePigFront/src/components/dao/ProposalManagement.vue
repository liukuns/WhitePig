<template>
  <div class="proposal-management">
    <button class="back-button" @click="$emit('goBack')">返回</button>
    <h2>内部提案管理</h2>
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
