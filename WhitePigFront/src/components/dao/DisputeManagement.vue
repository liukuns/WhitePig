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
          <th>证据</th>
          <th>支持票数</th>
          <th>反对票数</th>
          <th>投票执行</th>
          <th>被告人地址</th>
          <th>投票</th>
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
          <td>
            <button class="btn-detail" @click="showProof(dispute.proof)">查看证据</button>
          </td>
          <td>{{ dispute.supportVotes }}</td>
          <td>{{ dispute.againstVotes }}</td>
          <td>
            <span v-if="dispute.executed">已执行</span>
            <button v-else class="btn-execute" @click="executeDispute(dispute.id)">执行</button>
          </td>
          <td>{{ dispute.defendant }}</td>
          <td>
            <div v-if="!dispute.executed && new Date(dispute.voteDeadline) > new Date()">
              <button class="btn-vote" @click="openVoteModal(dispute.id, '支持')">支持</button>
              <button class="btn-vote" @click="openVoteModal(dispute.id, '反对')">反对</button>
            </div>
            <span v-else>投票已结束</span>
          </td>
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

    <!-- 投票弹窗 -->
    <div v-if="voteModalVisible" class="modal-overlay">
      <div class="modal">
        <h3>投票</h3>
        <p>您正在对纠纷 {{ currentVoteDisputeId }} 投票: {{ currentVoteType }}</p>
        <div class="modal-actions">
          <button class="btn-confirm" @click="submitVote">确认</button>
          <button class="btn-cancel" @click="closeVoteModal">取消</button>
        </div>
      </div>
    </div>

    <!-- 证据弹窗 -->
    <div v-if="proofModalVisible" class="modal-overlay">
      <div class="modal">
        <h3>证据详情</h3>
        <img :src="currentProofUrl" alt="证据图片" class="proof-image" />
        <button class="btn-close" @click="closeProofModal">关闭</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DisputeManagement',
  props: {
    rentDAOContract: { 
      type: Object,
      required: true
    }
  },
  data() {
    return {
      disputes: [
        { id: 20, transactionId: 'T101010', voteDeadline: '2027-03-01', description: '纠纷描述示例21', supportVotes: 14, againstVotes: 7, executed: false, defendant: '0xaaaa...bbbb', proof: 'https://example.com/proof1.jpg' },
        { id: 21, transactionId: 'T202020', voteDeadline: '2027-06-05', description: '纠纷描述示例22', supportVotes: 10, againstVotes: 5, executed: true, defendant: '0xbbbb...cccc', proof: 'https://example.com/proof2.jpg' }
      ],
      pageSize: 10, // 每页显示 10 个纠纷
      currentPage: 1,
      showModal: false,
      modalDescription: '',
      voteModalVisible: false, // 控制投票弹窗的显示
      currentVoteDisputeId: null, // 当前投票的纠纷 ID
      currentVoteType: '', // 当前投票类型（支持或反对）
      proofModalVisible: false, // 控制证据弹窗的显示
      currentProofUrl: '' // 当前显示的证据 URL
    };
  },
  async created() {
    try {
      const disputeCount = await this.rentDAOContract.disputeCount();
      console.log('纠纷数量:', disputeCount.toNumber());

      this.disputes = await Promise.all(
        Array.from({ length: disputeCount.toNumber() }).map(async (_, index) => {
          try {
            const dispute = await this.rentDAOContract.disputes(index);
            return {
              id: index,
              transactionId: dispute.dealId,
              voteDeadline: new Date(dispute.deadline * 1000).toISOString().split('T')[0],
              description: dispute.disputeDescription,
              supportVotes: dispute.votesFor.toNumber(),
              againstVotes: dispute.votesAgainst.toNumber(),
              executed: dispute.executed,
              defendant: dispute.roe,
              proof: dispute.proof // 添加证据字段
            };
          } catch (error) {
            console.error(`获取纠纷失败 (ID: ${index}):`, error);
            return null; // 跳过失败的纠纷
          }
        })
      );
      this.disputes = this.disputes.filter(dispute => dispute !== null); // 过滤掉无效的纠纷
    } catch (error) {
      console.error('加载纠纷列表失败:', error);
      alert('无法加载纠纷列表，请稍后重试');
    }
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
    async executeDispute(disputeId) {
      try {
        const dispute = await this.rentDAOContract.disputes(disputeId);
        if (dispute.executed) {
          alert(`纠纷 ${disputeId} 已执行`);
          return;
        }

        const confirmExecution = confirm(`您确定要执行纠纷 ${disputeId} 吗？`);
        if (!confirmExecution) return;

        const tx = await this.rentDAOContract.resolveDispute(disputeId);
        await tx.wait(); // 等待交易完成
        alert(`纠纷 ${disputeId} 已成功执行`);
        
        // 更新本地状态
        const localDispute = this.disputes.find(d => d.id === disputeId);
        if (localDispute) {
          localDispute.executed = true;
        }
      } catch (error) {
        console.error(`执行纠纷 ${disputeId} 失败:`, error);
        alert('执行失败，请稍后重试');
      }
    },
    openVoteModal(disputeId, voteType) {
      this.currentVoteDisputeId = disputeId;
      this.currentVoteType = voteType;
      this.voteModalVisible = true;
    },
    closeVoteModal() {
      this.voteModalVisible = false;
      this.currentVoteDisputeId = null;
      this.currentVoteType = '';
    },
    async submitVote() {
      try {
        if (!this.currentVoteDisputeId || !this.currentVoteType) {
          alert('投票信息不完整');
          return;
        }
        const isSupport = this.currentVoteType === '支持';
        console.log(`正在对纠纷 ${this.currentVoteDisputeId} 投票: ${this.currentVoteType}`);
        const tx = await this.rentDAOContract.voteOnDispute(this.currentVoteDisputeId, isSupport);
        await tx.wait(); // 等待交易完成
        alert(`您已成功投票: ${this.currentVoteType}`);
        this.closeVoteModal();
      } catch (error) {
        console.error('投票失败:', error);
        alert('投票失败，请稍后重试');
      }
    },
    showProof(proofUrl) {
      this.currentProofUrl = proofUrl;
      this.proofModalVisible = true;
    },
    closeProofModal() {
      this.proofModalVisible = false;
      this.currentProofUrl = '';
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
  background-color: #000000;
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
  background-color: #388a4b;
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

.btn-vote {
  padding: 5px 10px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  margin-right: 5px;
}

.btn-vote:hover {
  opacity: 0.9;
}

.modal-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 20px;
}

.btn-confirm {
  background-color: #28a745;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-cancel {
  background-color: #dc3545;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-confirm:hover,
.btn-cancel:hover {
  opacity: 0.9;
}

.proof-image {
  max-width: 100%;
  max-height: 400px;
  margin-bottom: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
}
</style>
