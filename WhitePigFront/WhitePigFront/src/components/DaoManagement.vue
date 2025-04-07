<template>
  <div class="dao-management">
    <div class="header">
      <h2>DAO管理</h2>
      <p>管理您的去中心化自治组织</p>
    </div>

    <div class="content">
      <div class="card">
        <h3>提案管理</h3>
        <p>查看和管理所有提案。</p>
        <button>查看提案</button>
      </div>

      <div class="card">
        <h3>成员管理</h3>
        <p>管理DAO成员的权限和角色。</p>
        <button>管理成员</button>
      </div>

      <div class="card">
        <h3>资金管理</h3>
        <p>查看和分配DAO的资金。</p>
        <button>管理资金</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DaoManagement'
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
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.card button:hover {
  background-color: #0056b3;
}
</style>
