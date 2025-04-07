<template>
  <div class="dispute-management">
    <button class="back-button" @click="$emit('goBack')">返回</button>
    <h2>纠纷列表</h2>
    <p>查看所有纠纷的详细信息。</p>

    <table class="dispute-table">
      <thead>
        <tr>
          <th>纠纷ID</th>
          <th>交易ID</th>
          <th>投票截至时间</th>
          <th>纠纷描述</th>
          <th>支持票数</th>
          <th>反对票数</th>
          <th>投票执行</th>
          <th>被告人地址</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="dispute in paginatedDisputes" :key="dispute.id">
          <td>{{ dispute.id }}</td>
          <td>{{ dispute.transactionId }}</td>
          <td>{{ dispute.voteDeadline }}</td>
          <td>
            <button class="btn-detail" @click="showDescription(dispute.description)">查看详情</button>
          </td>
          <td>{{ dispute.supportVotes }}</td>
          <td>{{ dispute.againstVotes }}</td>
          <td>
            <span v-if="dispute.executed">已执行</span>
            <button v-else class="btn-execute" @click="executeDispute(dispute.id)">执行</button>
          </td>
          <td>{{ dispute.defendant }}</td>
        </tr>
      </tbody>
    </table>

    <div class="pagination">
      <button class="btn-page" :disabled="currentPage === 1" @click="prevPage">上一页</button>
      <span>第 {{ currentPage }} 页 / 共 {{ totalPages }} 页</span>
      <button class="btn-page" :disabled="currentPage === totalPages" @click="nextPage">下一页</button>
    </div>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal">
        <h3>纠纷详情</h3>
        <p>{{ modalDescription }}</p>
        <button class="btn-close" @click="closeModal">关闭</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DisputeManagement',
  data() {
    return {
      disputes: [
        { id: 'D001', transactionId: 'T12345', voteDeadline: '2023-12-01', description: '纠纷描述示例1', supportVotes: 10, againstVotes: 5, executed: false, defendant: '0x1234...abcd' },
        { id: 'D002', transactionId: 'T67890', voteDeadline: '2023-12-05', description: '纠纷描述示例2', supportVotes: 8, againstVotes: 12, executed: true, defendant: '0x5678...efgh' },
        { id: 'D003', transactionId: 'T11111', voteDeadline: '2023-12-10', description: '纠纷描述示例3', supportVotes: 15, againstVotes: 3, executed: false, defendant: '0xaaaa...bbbb' },
        { id: 'D004', transactionId: 'T22222', voteDeadline: '2023-12-15', description: '纠纷描述示例4', supportVotes: 7, againstVotes: 9, executed: false, defendant: '0xcccc...dddd' },
        { id: 'D005', transactionId: 'T33333', voteDeadline: '2023-12-20', description: '纠纷描述示例5', supportVotes: 12, againstVotes: 6, executed: true, defendant: '0xeeee...ffff' },
        { id: 'D006', transactionId: 'T44444', voteDeadline: '2023-12-25', description: '纠纷描述示例6', supportVotes: 9, againstVotes: 8, executed: false, defendant: '0x1111...2222' },
        { id: 'D007', transactionId: 'T55555', voteDeadline: '2023-12-30', description: '纠纷描述示例7', supportVotes: 11, againstVotes: 4, executed: true, defendant: '0x3333...4444' },
        { id: 'D008', transactionId: 'T66666', voteDeadline: '2024-01-01', description: '纠纷描述示例8', supportVotes: 6, againstVotes: 10, executed: false, defendant: '0x5555...6666' },
        { id: 'D009', transactionId: 'T77777', voteDeadline: '2024-01-05', description: '纠纷描述示例9', supportVotes: 14, againstVotes: 2, executed: true, defendant: '0x7777...8888' },
        { id: 'D010', transactionId: 'T88888', voteDeadline: '2024-01-10', description: '纠纷描述示例10', supportVotes: 5, againstVotes: 7, executed: false, defendant: '0x9999...aaaa' },
        { id: 'D011', transactionId: 'T99999', voteDeadline: '2024-01-15', description: '纠纷描述示例11', supportVotes: 13, againstVotes: 6, executed: true, defendant: '0xbbbb...cccc' },
        { id: 'D012', transactionId: 'T10101', voteDeadline: '2024-01-20', description: '纠纷描述示例12', supportVotes: 8, againstVotes: 9, executed: false, defendant: '0xdddd...eeee' },
        { id: 'D013', transactionId: 'T20202', voteDeadline: '2024-01-25', description: '纠纷描述示例13', supportVotes: 10, againstVotes: 5, executed: true, defendant: '0xffff...1111' },
        { id: 'D014', transactionId: 'T30303', voteDeadline: '2024-01-30', description: '纠纷描述示例14', supportVotes: 7, againstVotes: 8, executed: false, defendant: '0x2222...3333' },
        { id: 'D015', transactionId: 'T40404', voteDeadline: '2024-02-01', description: '纠纷描述示例15', supportVotes: 9, againstVotes: 6, executed: true, defendant: '0x4444...5555' },
        { id: 'D016', transactionId: 'T50505', voteDeadline: '2024-02-05', description: '纠纷描述示例16', supportVotes: 11, againstVotes: 3, executed: false, defendant: '0x6666...7777' },
        { id: 'D017', transactionId: 'T60606', voteDeadline: '2024-02-10', description: '纠纷描述示例17', supportVotes: 12, againstVotes: 4, executed: true, defendant: '0x8888...9999' },
        { id: 'D018', transactionId: 'T70707', voteDeadline: '2024-02-15', description: '纠纷描述示例18', supportVotes: 8, againstVotes: 7, executed: false, defendant: '0xaaaa...bbbb' },
        { id: 'D019', transactionId: 'T80808', voteDeadline: '2024-02-20', description: '纠纷描述示例19', supportVotes: 10, againstVotes: 6, executed: true, defendant: '0xcccc...dddd' },
        { id: 'D020', transactionId: 'T90909', voteDeadline: '2024-02-25', description: '纠纷描述示例20', supportVotes: 13, againstVotes: 5, executed: false, defendant: '0xeeee...ffff' }
      ],
      pageSize: 10, // 每页显示 10 个纠纷
      currentPage: 1,
      showModal: false,
      modalDescription: ''
    };
  },
  computed: {
    totalPages() {
      return Math.ceil(this.disputes.length / this.pageSize);
    },
    paginatedDisputes() {
      const start = (this.currentPage - 1) * this.pageSize;
      const end = start + this.pageSize;
      return this.disputes.slice(start, end);
    }
  },
  methods: {
    prevPage() {
      if (this.currentPage > 1) {
        this.currentPage--;
      }
    },
    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++;
      }
    },
    showDescription(description) {
      this.modalDescription = description;
      this.showModal = true;
    },
    closeModal() {
      this.showModal = false;
      this.modalDescription = '';
    },
    executeDispute(disputeId) {
      const dispute = this.disputes.find(d => d.id === disputeId);
      if (dispute) {
        dispute.executed = true;
        alert(`纠纷 ${disputeId} 已执行`);
      }
    }
  }
};
</script>

<style scoped>
.dispute-management {
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

.dispute-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
}

.dispute-table th,
.dispute-table td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: center;
}

.dispute-table th {
  background-color: #f4f4f4;
  font-weight: bold;
}

.dispute-table tr:nth-child(even) {
  background-color: #f9f9f9;
}

.dispute-table tr:hover {
  background-color: #f1f1f1;
}

.pagination {
  margin-top: 10px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
}

.btn-page {
  padding: 5px 10px;
  background-color: #000;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-page:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.btn-detail {
  padding: 5px 10px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-detail:hover {
  opacity: 0.9;
}

.btn-execute {
  padding: 5px 10px;
  background-color: #28a745;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-execute:hover {
  opacity: 0.9;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal {
  background-color: white;
  padding: 20px;
  border-radius: 8px;
  width: 400px;
  text-align: center;
}

.modal h3 {
  margin-bottom: 10px;
}

.modal p {
  margin-bottom: 20px;
}

.btn-close {
  padding: 5px 10px;
  background-color: #000;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-close:hover {
  opacity: 0.9;
}
</style>
