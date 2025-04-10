<template>
  <div class="dispute-management">
    <div class="back-button-container">
      <button class="back-button" @click="$emit('goBack')">返回</button>
    </div>

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
          <td>{{ shortenAddress(dispute.defendant) }}</td>
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
    },
    shortenAddress(address) {
      if (!address) return '';
      return `${address.slice(0, 6)}...${address.slice(-4)}`;
    }
  }
};
</script>

<style scoped>
.dispute-management {
  padding: 20px;
  border-radius: 12px; /* 更大的圆角 */
  position: relative;
}

.back-button-container {
  margin-bottom: 20px; /* 添加与表格的间距 */
  text-align: left; /* 按钮靠左对齐 */
}

.back-button {
  padding: 10px 20px;
  background-color: #000;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
  transition: all 0.3s ease;
}

.back-button:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.dispute-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
  table-layout: fixed;
  border-radius: 12px; /* 表格圆角 */
  overflow: hidden; /* 防止圆角被覆盖 */
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); /* 表格阴影 */
}

.dispute-table th,
.dispute-table td {
  padding: 14px 18px; /* 增加内边距 */
  text-align: center;
  font-size: 14px;
  color: #555; /* 更柔和的字体颜色 */
  background-color: #fdfdfd; /* 更浅的背景色 */
  border-bottom: 1px solid #eee; /* 更浅的分隔线 */
  word-wrap: break-word;
}

.dispute-table th {
  font-weight: 600; /* 半粗字体 */
  background-color: #f8f9fa; /* 更浅的表头背景 */
  color: #333; /* 深灰色字体 */
}

.dispute-table tr:hover td {
  background-color: #f7f7f7; /* 鼠标悬停时更浅的背景 */
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 12px; /* 更大的间距 */
}

.btn-page {
  padding: 8px 16px; /* 更紧凑的按钮 */
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 6px; /* 更小的圆角 */
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-page:disabled {
  background-color: #e0e0e0; /* 更浅的禁用背景 */
  color: #999; /* 更浅的禁用字体颜色 */
  cursor: not-allowed;
}

.btn-detail {
  padding: 8px 16px; /* 更紧凑的按钮 */
  color: #fff;
  border: none;
  border-radius: 6px; /* 更小的圆角 */
  font-size: 14px;
  font-weight: 500; /* 中等粗细 */
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-detail:hover {
  transform: translateY(-1px); /* 轻微上移 */
}

.btn-execute {
  padding: 8px 16px; /* 更紧凑的按钮 */
  background-color: #f0f0f0; /* 浅灰色背景 */
  color: #000; /* 黑色字体 */
  border: none;
  border-radius: 6px; /* 更小的圆角 */
  font-size: 14px;
  font-weight: 500; /* 中等粗细 */
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* 柔和阴影 */
}

.btn-execute:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* 鼠标悬停时更深的阴影 */
  transform: translateY(-1px); /* 轻微上移 */
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
  background-color: #ffffff;
  padding: 24px; /* 更大的内边距 */
  border-radius: 12px; /* 更大的圆角 */
  width: 420px; /* 更宽的弹窗 */
  text-align: center;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2); /* 更深的阴影 */
}

.modal h3 {
  margin-bottom: 16px; /* 更大的标题间距 */
  font-size: 18px; /* 更大的字体 */
  font-weight: 600; /* 半粗字体 */
  color: #333; /* 深灰色字体 */
}

.modal p {
  margin-bottom: 24px; /* 更大的段落间距 */
  font-size: 14px;
  color: #555; /* 更柔和的字体颜色 */
}

.btn-close {
  padding: 8px 16px; /* 更紧凑的按钮 */
  color: #fff;
  border: none;
  border-radius: 6px; /* 更小的圆角 */
  font-size: 14px;
  font-weight: 500; /* 中等粗细 */
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-close:hover {
  transform: translateY(-1px); /* 轻微上移 */
}

.btn-vote {
  padding: 8px 16px; /* 更紧凑的按钮 */
  color: #fff;
  border: none;
  border-radius: 6px; /* 更小的圆角 */
  font-size: 14px;
  font-weight: 500; /* 中等粗细 */
  cursor: pointer;
  transition: all 0.3s ease;
  margin-right: 5px;
}

.btn-vote:hover {
  transform: translateY(-1px); /* 轻微上移 */
}

.modal-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 20px;
}

.btn-confirm {
  padding: 8px 16px; /* 更紧凑的按钮 */
  background-color: #007bff; /* 统一按钮颜色 */
  color: #fff;
  border: none;
  border-radius: 6px; /* 更小的圆角 */
  font-size: 14px;
  font-weight: 500; /* 中等粗细 */
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-confirm:hover {
  background-color: #0056b3; /* 深蓝色悬停效果 */
  transform: translateY(-1px); /* 轻微上移 */
}

.btn-cancel {
  padding: 8px 16px; /* 更紧凑的按钮 */
  background-color: #007bff; /* 统一按钮颜色 */
  color: #fff;
  border: none;
  border-radius: 6px; /* 更小的圆角 */
  font-size: 14px;
  font-weight: 500; /* 中等粗细 */
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-cancel:hover {
  background-color: #0056b3; /* 深蓝色悬停效果 */
  transform: translateY(-1px); /* 轻微上移 */
}

.proof-image {
  max-width: 100%;
  max-height: 400px;
  margin-bottom: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
}

.back-button,
.btn-page,
.btn-detail,
.btn-execute,
.btn-vote,
.btn-close,
.btn-confirm,
.btn-cancel {
  padding: 10px 20px;
  background-color: #f0f0f0;
  color: #333; /* 深灰色文字 */
  border: none;
  border-radius: 10px; /* 圆角按钮 */
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  font-size: 14px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease; /* 添加过渡效果 */
}

.back-button:hover,
.btn-page:hover:not(:disabled),
.btn-detail:hover,
.btn-execute:hover,
.btn-vote:hover,
.btn-close:hover,
.btn-confirm:hover,
.btn-cancel:hover {
  transform: translateY(-2px); /* 轻微上移 */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* 添加阴影效果 */
}

.btn-page:disabled {
  background-color: #ccc;
  color: #666;
  cursor: not-allowed;
  border-color: #ccc;
}

.btn-execute {
  background-color: #f0f0f0; /* 绿色背景 */
  color: #000000;
  border: none;
}

.btn-execute:hover {
  background-color: #fefefe; /* 深绿色悬停效果 */
}

.btn-confirm {
  background-color: #007bff; /* 蓝色背景 */
  color: #ffffff;
  border: none;
}

.btn-confirm:hover {
  background-color: #0056b3; /* 深蓝色悬停效果 */
}

.btn-cancel {
  background-color: #dc3545; /* 红色背景 */
  color: #ffffff;
  border: none;
}

.btn-cancel:hover {
  background-color: #c82333; /* 深红色悬停效果 */
}
</style>
