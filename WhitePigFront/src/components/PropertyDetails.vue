<template>
  <div class="property-details">
    <section class="property-info">
      <h2>房子详细信息</h2>
      <div class="info-item">
        <span class="label">房源编号:</span>
        <span class="value">{{ property.id }}</span>
      </div>
      <div class="info-item">
        <span class="label">月租金:</span>
        <span class="value">¥{{ property.rent }}</span>
      </div>
      <div class="info-item">
        <span class="label">房屋类型:</span>
        <span class="value">{{ property.type }}</span>
      </div>
      <div class="info-item">
        <span class="label">是否可租:</span>
        <span class="value">{{ property.isAvailable }}</span>
      </div>
      <div class="info-item">
        <span class="label">是否下架:</span>
        <span class="value">{{ property.isWithdraw }}</span>
      </div>
    </section>

    <section class="actions">
      <h3>操作</h3>
      <button class="btn btn-close" @click="$emit('close')">关闭</button>
      <button class="btn btn-update" @click="showModal('removedStatus')">更新下架状态</button>
      <button class="btn btn-update" @click="showModal('rent')">更新月租金</button>
      <button class="btn btn-update" @click="showModal('description')">更新房屋描述</button>
    </section>

    <div v-if="modalVisible" class="modal-overlay">
      <div class="modal">
        <h3>{{ modalTitle }}</h3>
        <p class="modal-hint">{{ modalHint }}</p>
        <input v-model="modalInput" :placeholder="modalPlaceholder" />
        <div class="modal-actions">
          <button class="btn btn-confirm" @click="handleModalConfirm">确认</button>
          <button class="btn btn-cancel" @click="closeModal">取消</button>
        </div>
      </div>
    </div>

    <!-- 联系请求表格 -->
    <section class="contact-requests">
      <h3>联系请求</h3>
      <table class="requests-table">
        <thead>
          <tr>
            <th>发送者地址</th>
            <th>发送内容</th>
            <th>是否同意</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(request, index) in paginatedRequests" :key="index">
            <td>{{ request.sender }}</td>
            <td>{{ request.message }}</td>
            <td>{{ request.approved ? '已同意' : '未处理' }}</td>
            <td>
              <button class="btn btn-handle" @click="openApprovalModal(index + (currentPage - 1) * pageSize)">处理</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="pagination">
        <button class="btn btn-page" :disabled="currentPage === 1" @click="prevPage">上一页</button>
        <span>第 {{ currentPage }} 页 / 共 {{ totalPages }} 页</span>
        <button class="btn btn-page" :disabled="currentPage === totalPages" @click="nextPage">下一页</button>
      </div>
    </section>

    <!-- 处理请求弹窗 -->
    <div v-if="approvalModalVisible" class="modal-overlay">
      <div class="modal">
        <h3>处理联系请求</h3>
        <p>发送者地址: {{ currentRequest.sender }}</p>
        <p>发送内容: {{ currentRequest.message }}</p>
        <div class="modal-actions">
          <button class="btn btn-confirm" @click="approveRequest">同意</button>
          <button class="btn btn-cancel" @click="rejectRequest">拒绝</button>
        </div>
      </div>
    </div>

    <!-- 租房请求表格 -->
    <section class="rental-requests">
      <h3>租房请求</h3>
      <table class="requests-table">
        <thead>
          <tr>
            <th>发送者地址</th>
            <th>发送内容</th>
            <th>请求状态</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(request, index) in paginatedRentalRequests" :key="index">
            <td>{{ request.sender }}</td>
            <td>{{ request.message }}</td>
            <td>{{ request.approved ? '已同意' : '未处理' }}</td>
            <td>
              <button class="btn btn-handle" @click="openRentalApprovalModal(index + (rentalCurrentPage - 1) * rentalPageSize)">处理</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="pagination">
        <button class="btn btn-page" :disabled="rentalCurrentPage === 1" @click="prevRentalPage">上一页</button>
        <span>第 {{ rentalCurrentPage }} 页 / 共 {{ rentalTotalPages }} 页</span>
        <button class="btn btn-page" :disabled="rentalCurrentPage === rentalTotalPages" @click="nextRentalPage">下一页</button>
      </div>
    </section>

    <!-- 处理租房请求弹窗 -->
    <div v-if="rentalApprovalModalVisible" class="modal-overlay">
      <div class="modal">
        <h3>处理租房请求</h3>
        <p>发送者地址: {{ currentRentalRequest.sender }}</p>
        <p>租期（月）: {{ currentRentalRequest.months }}</p>
        <div class="modal-actions">
          <button class="btn btn-confirm" @click="approveRentalRequest">同意</button>
          <button class="btn btn-cancel" @click="rejectRentalRequest">拒绝</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PropertyDetails',
  props: {
    property: {
      type: Object,
      required: true
    },
    propertyManagementContract: {
      type: Object,
      required: true
    },
    rentRequestContract: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      modalVisible: false,
      modalTitle: '',
      modalPlaceholder: '',
      modalInput: '',
      currentAction: '',
      modalHint: '',
      contactRequests: [],
      approvalModalVisible: false,
      currentRequestIndex: null,
      pageSize: 5,
      currentPage: 1,
      rentalRequests: [],
      rentalApprovalModalVisible: false,
      currentRentalRequestIndex: null,
      rentalPageSize: 5,
      rentalCurrentPage: 1
    };
  },
  async created() {
    try {
      const allContactRequests = await this.rentRequestContract.getConRequests(false);
      this.contactRequests = allContactRequests
        .filter(request => request.propertyId === this.property.id)
        .map(request => ({
          sender: request.sender,
          message: request.content,
          approved: request.approved
        }));

      const allRentalRequests = await this.rentRequestContract.getRentRequests(false);
      this.rentalRequests = allRentalRequests
        .filter(request => request.propertyId === this.property.id)
        .map(request => ({
          sender: request.sender,
          message: request.content,
          months: request.months,
          approved: request.approved
        }));
    } catch (error) {
      console.error('获取请求失败:', error);
      alert('无法加载请求，请稍后重试');
    }
  },
  computed: {
    totalPages() {
      return Math.ceil(this.contactRequests.length / this.pageSize);
    },
    paginatedRequests() {
      const start = (this.currentPage - 1) * this.pageSize;
      const end = start + this.pageSize;
      return this.contactRequests.slice(start, end);
    },
    currentRequest() {
      return this.contactRequests[this.currentRequestIndex] || {};
    },
    rentalTotalPages() {
      return Math.ceil(this.rentalRequests.length / this.rentalPageSize);
    },
    paginatedRentalRequests() {
      const start = (this.rentalCurrentPage - 1) * this.rentalPageSize;
      const end = start + this.rentalPageSize;
      return this.rentalRequests.slice(start, end);
    },
    currentRentalRequest() {
      return this.rentalRequests[this.currentRentalRequestIndex] || {};
    }
  },
  methods: {
    isRentable(id) {
      return true; // 模拟函数
    },
    isRemoved(id) {
      return true; // 模拟函数
    },
    showModal(action) {
      this.currentAction = action;
      this.modalVisible = true;
      if (action === 'removedStatus') {
        this.modalTitle = '更新下架状态';
        this.modalPlaceholder = '请输入 true 或 false';
        this.modalHint = '提示: 输入 true 表示下架，输入 false 表示未下架';
      } else if (action === 'rent') {
        this.modalTitle = '更新月租金';
        this.modalPlaceholder = '请输入新的月租金';
        this.modalHint = '提示: 输入有效的数字作为月租金';
      } else if (action === 'description') {
        this.modalTitle = '更新房屋描述';
        this.modalPlaceholder = '请输入新的房屋描述';
        this.modalHint = '提示: 输入简洁明了的房屋描述';
      }
    },
    closeModal() {
      this.modalVisible = false;
      this.modalInput = '';
    },
    async handleModalConfirm() {
      console.log('合约实例:', this.propertyManagementContract);
      try {
        if (this.currentAction === 'removedStatus') {
          const newStatus = this.modalInput.toLowerCase() === 'true';
          await this.propertyManagementContract.updateWithdrawal(this.property.id, newStatus);
          alert('下架状态更新成功！');
          this.property.isWithdraw = newStatus; // 更新本地状态
        } else if (this.currentAction === 'rent') {
          const newRent = parseFloat(this.modalInput);
          if (!isNaN(newRent)) {
            await this.propertyManagementContract.updateMonthlyRent(this.property.id, newRent);
            alert('月租金更新成功！');
            this.property.rent = newRent; // 更新本地状态
          } else {
            alert('请输入有效的月租金！');
          }
        } else if (this.currentAction === 'description') {
          const newDescription = this.modalInput.trim();
          if (newDescription) {
            await this.propertyManagementContract.updateMonthlyDescription(this.property.id, newDescription);
            alert('房屋描述更新成功！');
            this.property.description = newDescription; // 更新本地状态
          } else {
            alert('房屋描述不能为空！');
          }
        }
      } catch (error) {
        console.error('更新失败:', error);
        alert('更新失败，请重试！');
      } finally {
        this.closeModal();
      }
    },
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
    openApprovalModal(index) {
      this.currentRequestIndex = index;
      this.approvalModalVisible = true;
    },
    async approveRequest() {
      try {
        const requestId = this.contactRequests[this.currentRequestIndex].id;
        await this.rentRequestContract.handleConRequest(requestId, true);
        alert('请求已同意！');
        this.contactRequests[this.currentRequestIndex].approved = true; // 更新本地状态
      } catch (error) {
        console.error('处理请求失败:', error);
        alert('处理请求失败，请稍后重试！');
      } finally {
        this.closeApprovalModal();
      }
    },
    async rejectRequest() {
      try {
        const requestId = this.contactRequests[this.currentRequestIndex].id;
        await this.rentRequestContract.handleConRequest(requestId, false);
        alert('请求已拒绝！');
        this.contactRequests[this.currentRequestIndex].approved = false; // 更新本地状态
      } catch (error) {
        console.error('处理请求失败:', error);
        alert('处理请求失败，请稍后重试！');
      } finally {
        this.closeApprovalModal();
      }
    },
    closeApprovalModal() {
      this.approvalModalVisible = false;
      this.currentRequestIndex = null;
    },
    prevRentalPage() {
      if (this.rentalCurrentPage > 1) {
        this.rentalCurrentPage--;
      }
    },
    nextRentalPage() {
      if (this.rentalCurrentPage < this.rentalTotalPages) {
        this.rentalCurrentPage++;
      }
    },
    openRentalApprovalModal(index) {
      this.currentRentalRequestIndex = index;
      this.rentalApprovalModalVisible = true;
    },
    async approveRentalRequest() {
      try {
        const requestId = this.rentalRequests[this.currentRentalRequestIndex].id;
        await this.rentRequestContract.handleRentRequest(requestId, true);
        alert('租房请求已同意！');
        this.rentalRequests[this.currentRentalRequestIndex].approved = true; // 更新本地状态
      } catch (error) {
        console.error('处理租房请求失败:', error);
        alert('处理租房请求失败，请稍后重试！');
      } finally {
        this.closeRentalApprovalModal();
      }
    },
    async rejectRentalRequest() {
      try {
        const requestId = this.rentalRequests[this.currentRentalRequestIndex].id;
        await this.rentRequestContract.handleRentRequest(requestId, false);
        alert('租房请求已拒绝！');
        this.rentalRequests[this.currentRentalRequestIndex].approved = false; // 更新本地状态
      } catch (error) {
        console.error('处理租房请求失败:', error);
        alert('处理租房请求失败，请稍后重试！');
      } finally {
        this.closeRentalApprovalModal();
      }
    },
    closeRentalApprovalModal() {
      this.rentalApprovalModalVisible = false;
      this.currentRentalRequestIndex = null;
    }
  }
};
</script>

<style scoped>
.property-details {
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 10px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  font-family: 'Arial', sans-serif;
}

.property-info {
  background-color: #fff;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}

.info-item:last-child {
  border-bottom: none;
}

.label {
  font-weight: bold;
  color: #333;
}

.value {
  color: #555;
}

.actions {
  margin-top: 20px;
}

.actions .btn {
  margin: 5px;
  padding: 10px 20px;
  font-size: 14px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.btn-close {
  background-color: #6c757d;
  color: #fff;
}

.btn-update {
  background-color: #007bff;
  color: #fff;
}

.btn:hover {
  opacity: 0.9;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal {
  background: #fff;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
  text-align: center;
  width: 400px;
}

.modal input {
  width: 90%;
  padding: 10px;
  margin: 15px 0;
  border: 1px solid #ddd;
  border-radius: 5px;
}

.modal-actions {
  display: flex;
  justify-content: space-between;
}

.modal-actions .btn {
  flex: 1;
  margin: 0 5px;
}

.btn-confirm {
  background-color: #28a745;
  color: #fff;
}

.btn-cancel {
  background-color: #dc3545;
  color: #fff;
}

.contact-requests {
  margin-top: 20px;
}

.requests-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
}

.requests-table th,
.requests-table td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: center;
}

.requests-table th {
  background-color: #f4f4f4;
  font-weight: bold;
}

.btn-handle {
  background-color: #ffc107;
  color: #fff;
}

.btn-handle:hover {
  opacity: 0.9;
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
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.btn-page:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

/* 租房请求表格样式 */
.rental-requests {
  margin-top: 20px;
}

.actions .btn,
.modal-actions .btn,
.pagination .btn-page,
.requests-table .btn-handle {
  background-color: #000; /* 修改为黑色背景 */
  color: #fff; /* 修改为白色文字 */
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.actions .btn:hover,
.modal-actions .btn:hover,
.pagination .btn-page:hover,
.requests-table .btn-handle:hover {
  opacity: 0.9; /* 鼠标悬停时稍微变暗 */
}

.btn-page:disabled {
  background-color: #ccc; /* 禁用按钮保持灰色 */
  color: #fff; /* 禁用按钮文字仍为白色 */
  cursor: not-allowed;
}
</style>