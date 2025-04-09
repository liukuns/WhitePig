<template>
  <div class="transaction-details">
    <div class="header">
      <button class="back-button" @click="$emit('go-back')">返回</button>
    </div>

    <h2>租房交易详情</h2>

    <div class="details">
      <div class="detail-item">
        <span class="label">房产编号:</span>
        <span class="value">{{ transaction?.propertyId || '无' }}</span>
      </div>
      <div class="detail-item">
        <span class="label">起租时间:</span>
        <span class="value">{{ transaction?.startDate || '无' }}</span>
      </div>
      <div class="detail-item">
        <span class="label">结租时间:</span>
        <span class="value">{{ transaction?.endDate || '无' }}</span>
      </div>
      <div class="detail-item">
        <span class="label">是否完成:</span>
        <span class="value">{{ transaction?.isCompleted ? '是' : '否' }}</span>
      </div>
      <div class="detail-item">
        <span class="label">是否纠纷:</span>
        <span class="value">{{ transaction?.isDisputed ? '是' : '否' }}</span>
      </div>
      <div class="detail-item">
        <span class="label">租房合同:</span>
        <span class="value">{{ transaction?.contractCID || '无' }}</span>
      </div>
    </div>

    <div class="actions">
      <div v-if="hasReviewed" class="review-section">
        <h3>评价</h3>
        <p>{{ transaction.review }}</p>
      </div>
      <div v-else>
        <button class="action-button" @click="openReviewModal">发起评价</button>
      </div>

      <div v-if="hasComplained" class="complaint-section">
        <h3>投诉</h3>
        <p>{{ transaction.complaint }}</p>
      </div>
      <div v-else>
        <button class="action-button" @click="openComplaintModal">投诉</button>
      </div>
    </div>

    <!-- 评价弹窗 -->
    <div v-if="showReviewModal" class="modal-overlay">
      <div class="modal">
        <h3>提交评价</h3>
        <label for="review-score">评分 (1-100):</label>
        <input
          id="review-score"
          type="number"
          v-model="reviewScore"
          min="1"
          max="100"
          placeholder="请输入评分"
        />
        <label for="review-description">评价描述:</label>
        <textarea
          id="review-description"
          v-model="reviewDescription"
          placeholder="请输入评价描述"
        ></textarea>
        <div class="modal-buttons">
          <button @click="submitReview">提交</button>
          <button @click="closeReviewModal">取消</button>
        </div>
      </div>
    </div>

    <!-- 投诉弹窗 -->
    <div v-if="showComplaintModal" class="modal-overlay">
      <div class="modal">
        <h3>提交投诉</h3>
        <label for="complaint-description">投诉描述:</label>
        <textarea
          id="complaint-description"
          v-model="complaintDescription"
          placeholder="请输入投诉描述"
        ></textarea>
        <label for="evidence-upload">上传证据:</label>
        <input
          id="evidence-upload"
          type="file"
          @change="handleEvidenceUpload"
        />
        <div class="modal-buttons">
          <button @click="submitComplaint">提交</button>
          <button @click="closeComplaintModal">取消</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { create } from 'ipfs-http-client';

export default {
  name: 'TransactionDetails',
  props: {
    transaction: {
      type: Object,
      required: false, // 设置为非必需，避免未传递时报错
      default: () => ({}) // 默认值为空对象
    },
    currentUserAddress: { // 新增当前用户地址的 prop
      type: String,
      required: true
    },
    propertyMarketContract: { // 新增 propertyMarket 合约的 prop
      type: Object,
      required: true
    },
    rentDAOContract: { // 新增 propertyMarket 合约的 prop
      type: Object,
      required: true
    }
  },
  data() {
    return {
      showReviewModal: false,
      reviewScore: '',
      reviewDescription: '',
      showComplaintModal: false,
      complaintDescription: '',
      evidenceFile: null,
      ipfsClient: null, // IPFS 客户端实例
      hasReviewed: false, // 是否已评价
      hasComplained: false // 是否已投诉
    };
  },
  async created() {
    try {
      const remark = await this.propertyMarketContract.getRemark(
        this.transaction.propertyId,
        this.currentUserAddress
      );
      if (remark.isRemark) {
        this.hasReviewed = true;
        this.transaction.review = `评分: ${remark.grade}, 描述: ${remark.wards}`;
      } else {
        this.hasReviewed = false;
      }

      // 初始化 IPFS 客户端，连接到本地 IPFS 节点
      this.ipfsClient = create({
        url: 'http://127.0.0.1:5001/api/v0' // 本地 IPFS 节点地址
      });

      // 判断用户是否已评价或投诉
      this.checkReviewAndComplaint();
      await this.checkComplaintStatus(); // 检查纠纷状态
    } catch (error) {
      console.error('初始化失败:', error);
    }
  },
  methods: {
    async checkReviewAndComplaint() {
      try {
        const remark = await this.propertyMarketContract.getRemark(
          this.transaction.propertyId,
          this.currentUserAddress
        );
        if (remark.isRemark) {
          this.hasReviewed = true;
          this.transaction.review = `评分: ${remark.grade}, 描述: ${remark.wards}`;
        } else {
          this.hasReviewed = false;
          this.openReviewModal(); // 如果未评价，直接打开评价弹窗
        }
      } catch (error) {
        console.error('获取评价信息失败:', error);
      }
    },
    async checkComplaintStatus() {
      try {
        const disputeCount = await this.rentDAOContract.disputeCount();
        for (let i = 0; i < disputeCount.toNumber(); i++) {
          const dispute = await this.rentDAOContract.disputes(i);
          const deal = await this.rentDAOContract.deals(dispute.dealId);
          if (deal.propertyId === this.transaction.propertyId) {
            if (deal.isDisputed) {
              this.hasComplained = true;
              this.transaction.complaint = `纠纷已提交，纠纷编号: ${i}`;
              return;
            }
          }
        }
        this.hasComplained = false; // 如果没有找到相关纠纷
      } catch (error) {
        console.error('获取纠纷状态失败:', error);
      }
    },
    openReviewModal() {
      this.showReviewModal = true;
    },
    closeReviewModal() {
      this.showReviewModal = false;
      this.reviewScore = '';
      this.reviewDescription = '';
    },
    async submitReview() {
      if (!this.reviewScore || !this.reviewDescription) {
        alert('请填写评分和评价描述');
        return;
      }
      this.$emit('update-transaction', {
        ...this.transaction,
        review: `评分: ${this.reviewScore}, 描述: ${this.reviewDescription}`
      });
      alert('评价已提交');
      this.closeReviewModal();
    },
    openComplaintModal() {
      this.showComplaintModal = true;
    },
    closeComplaintModal() {
      this.showComplaintModal = false;
      this.complaintDescription = '';
      this.evidenceFile = null;
    },
    handleEvidenceUpload(event) {
      this.evidenceFile = event.target.files[0];
    },
    async submitComplaint() {
      if (!this.complaintDescription || !this.evidenceFile) {
        alert('请填写投诉描述并上传证据');
        return;
      }
      try {
        const ipfsLink = await this.uploadToIPFS(this.evidenceFile);
        console.log('证据上传成功:', ipfsLink);
        alert(`投诉已提交: 描述=${this.complaintDescription}, 证据CID=${ipfsLink}`);
        this.closeComplaintModal();
      } catch (error) {
        console.error('证据上传失败:', error);
        alert('证据上传失败，请重试');
      }
    },
    async uploadToIPFS(file) {
      try {
        const added = await this.ipfsClient.add(file);
        return added.path; // 返回 IPFS CID
      } catch (error) {
        throw new Error('IPFS 上传失败');
      }
    }
  }
};
</script>

<style scoped>
.transaction-details {
  font-family: 'Cursive', 'Arial', sans-serif;
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.header h2 {
  font-size: 24px;
  color: #333;
}

.back-button {
  padding: 10px 20px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.back-button:hover {
  background-color: #0056b3;
}

.details {
  margin-bottom: 20px;
  padding: 20px;
  background-color: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.detail-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
}

.detail-item .label {
  font-weight: bold;
  color: #555;
}

.detail-item .value {
  color: #333;
}

.actions {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.action-button {
  padding: 10px 20px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  text-align: center;
}

.action-button:hover {
  background-color: #0056b3;
}

.review-section,
.complaint-section {
  padding: 20px;
  background-color: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
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
  padding: 20px;
  border-radius: 8px;
  width: 400px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.modal h3 {
  margin-bottom: 10px;
}

.modal textarea {
  width: 95%;
  height: 100px;
  margin-bottom: 10px;
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 4px;
  resize: none;
}

.modal input[type="number"],
.modal input[type="file"] {
  width: 95%;
  margin-bottom: 10px;
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.modal-buttons {
  display: flex;
  justify-content: space-between;
}

.modal-buttons button {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.modal-buttons button:first-child {
  background-color: #007bff;
  color: white;
}

.modal-buttons button:last-child {
  background-color: #ccc;
  color: black;
}
</style>
