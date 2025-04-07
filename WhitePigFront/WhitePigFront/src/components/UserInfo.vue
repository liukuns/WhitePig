<template>
  <div class="user-info">
    <!-- 用户身份认证 -->
    <div v-if="!isVerified" class="auth-section">
      <h3>身份认证</h3>
      <label for="id-number">身份证号:</label>
      <input id="id-number" v-model="idNumber" placeholder="请输入身份证号" />

      <label for="phone-number">手机号:</label>
      <input id="phone-number" v-model="phoneNumber" placeholder="请输入手机号" />

      <button @click="sendVerificationCode">获取验证码</button>

      <label v-if="verificationSent" for="verification-code">验证码:</label>
      <input
        v-if="verificationSent"
        id="verification-code"
        v-model="verificationCode"
        placeholder="请输入验证码"
      />

      <button v-if="verificationSent" @click="verifyIdentity">验证身份</button>
    </div>

    <!-- 用户信息显示 -->
    <div v-else>
      <h2>我的信息</h2>
      <div class="user-details">
        <p><strong>数字身份证:</strong> {{ digitalId }}</p>
        <p><strong>钱包地址:</strong> {{ walletAddress }}</p>
        <p><strong>信誉积分:</strong> {{ reputationScore }}</p>
        <p><strong>手机号:</strong> {{ phoneNumber }}</p>
        <p><strong>身份认证绑定:</strong> {{ isVerified ? '已绑定' : '未绑定' }}</p>
      </div>

      <!-- 用户请求模块 -->
      <div class="requests-container">
        <h3>我的请求</h3>
        <div class="request-box">
          <h4>联系请求</h4>
          <table>
            <thead>
              <tr>
                <th>房源编号</th>
                <th>接收方地址</th>
                <th>发送内容</th>
                <th>是否同意</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(request, index) in paginatedContactRequests"
                :key="index"
                :class="{ highlighted: selectedContactRequest === index }"
                @click="selectContactRequest(index)"
              >
                <td>{{ request.propertyId }}</td>
                <td>{{ shortenAddress(request.receiver) }}</td>
                <td>{{ request.content }}</td>
                <td>{{ request.isApproved ? '是' : '否' }}</td>
              </tr>
            </tbody>
          </table>
          <div class="pagination">
            <button @click="prevContactPage" :disabled="contactCurrentPage === 1">上一页</button>
            <span>第 {{ contactCurrentPage }} 页 / 共 {{ contactTotalPages }} 页</span>
            <button @click="nextContactPage" :disabled="contactCurrentPage === contactTotalPages">下一页</button>
          </div>
        </div>

        <div class="request-box">
          <h4>租房请求</h4>
          <table>
            <thead>
              <tr>
                <th>房源编号</th>
                <th>接收方地址</th>
                <th>发送内容</th>
                <th>是否同意</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(request, index) in paginatedRentalRequests"
                :key="index"
                :class="{ highlighted: selectedRentalRequest === index }"
                @click="selectRentalRequest(index)"
              >
                <td>{{ request.propertyId }}</td>
                <td>{{ shortenAddress(request.receiver) }}</td>
                <td>{{ request.content }}</td>
                <td>{{ request.isApproved ? '是' : '否' }}</td>
              </tr>
            </tbody>
          </table>
          <div class="pagination">
            <button @click="prevRentalPage" :disabled="rentalCurrentPage === 1">上一页</button>
            <span>第 {{ rentalCurrentPage }} 页 / 共 {{ rentalTotalPages }} 页</span>
            <button @click="nextRentalPage" :disabled="rentalCurrentPage === rentalTotalPages">下一页</button>
          </div>
        </div>
      </div>

      <!-- 租房交易模块 -->
      <div v-if="!showTransactionDetails" class="transactions-container">
        <h3>我的租房交易</h3>
        <table>
          <thead>
            <tr>
              <th>房产编号</th>
              <th>起租时间</th>
              <th>结租时间</th>
              <th>是否完成</th>
              <th>是否纠纷</th>
              <th>租房合同</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(transaction, index) in paginatedRentalTransactions"
              :key="index"
              :class="{ highlighted: selectedTransaction === index }"
              @click="selectTransaction(index)"
            >
              <td>{{ transaction.propertyId }}</td>
              <td>{{ transaction.startDate }}</td>
              <td>{{ transaction.endDate }}</td>
              <td>{{ transaction.isCompleted ? '是' : '否' }}</td>
              <td>{{ transaction.isDisputed ? '是' : '否' }}</td>
              <td>{{ transaction.contractCID }}</td>
              <td>
                <button @click.stop="$emit('view-transaction', transaction)">查看详情</button>
              </td>
            </tr>
          </tbody>
        </table>
        <div class="pagination">
          <button @click="prevTransactionPage" :disabled="transactionCurrentPage === 1">上一页</button>
          <span>第 {{ transactionCurrentPage }} 页 / 共 {{ transactionTotalPages }} 页</span>
          <button @click="nextTransactionPage" :disabled="transactionCurrentPage === transactionTotalPages">下一页</button>
        </div>
      </div>

      <!-- 租房交易详情 -->
      <TransactionDetails
        v-else
        :transaction="selectedTransactionDetails"
        @go-back="showTransactionDetails = false"
      />
    </div>
  </div>
</template>

<script>
import TransactionDetails from './TransactionDetails.vue';

export default {
  name: 'UserInfo',
  components: {
    TransactionDetails
  },
  data() {
    return {
      idNumber: '',
      phoneNumber: '',
      verificationCode: '',
      verificationSent: false,
      // isVerified: false,
      isVerified: true,
      digitalId: '1234567890abcdef',
      walletAddress: '0x12...3456',
      reputationScore: 85,
      selectedContactRequest: null, // 高亮的联系请求索引
      selectedRentalRequest: null, // 高亮的租房请求索引
      selectedTransaction: null, // 高亮的租房交易索引
      contactRequests: [
        {
          propertyId: '001',
          receiver: '0x1234567890abcdef1234567890abcdef12345678',
          content: '希望联系房东了解更多信息',
          isApproved: false
        },
        { propertyId: '002', receiver: '0xabcdef...', content: '联系房东', isApproved: true },
        { propertyId: '003', receiver: '0x123456...', content: '联系房东', isApproved: false },
        { propertyId: '004', receiver: '0xabcdef...', content: '联系房东', isApproved: true },
        { propertyId: '005', receiver: '0x123456...', content: '联系房东', isApproved: false },
        { propertyId: '006', receiver: '0xabcdef...', content: '联系房东', isApproved: true },
        { propertyId: '007', receiver: '0x123456...', content: '联系房东', isApproved: false },
        { propertyId: '008', receiver: '0xabcdef...', content: '联系房东', isApproved: true }
      ],
      rentalRequests: [
        {
          propertyId: '002',
          receiver: '0xabcdef1234567890abcdef1234567890abcdef12',
          content: '申请租房，请求批准',
          isApproved: true
        },
        { propertyId: '009', receiver: '0xabcdef...', content: '申请租房', isApproved: true },
        { propertyId: '010', receiver: '0x123456...', content: '申请租房', isApproved: false },
        { propertyId: '011', receiver: '0xabcdef...', content: '申请租房', isApproved: true },
        { propertyId: '012', receiver: '0x123456...', content: '申请租房', isApproved: false },
        { propertyId: '013', receiver: '0xabcdef...', content: '申请租房', isApproved: true },
        { propertyId: '014', receiver: '0x123456...', content: '申请租房', isApproved: false },
        { propertyId: '015', receiver: '0xabcdef...', content: '申请租房', isApproved: true }
      ],
      rentalTransactions: [
        {
          propertyId: '003',
          startDate: '2023-01-01',
          endDate: '2023-12-31',
          isCompleted: true,
          isDisputed: false,
          contractCID: 'Qm1234567890abcdef'
        },
        { propertyId: '016', startDate: '2023-01-01', endDate: '2023-12-31', isCompleted: true, isDisputed: false, contractCID: 'Qm123...' },
        { propertyId: '017', startDate: '2023-02-01', endDate: '2023-11-30', isCompleted: false, isDisputed: true, contractCID: 'Qm456...' },
        { propertyId: '018', startDate: '2023-03-01', endDate: '2023-10-31', isCompleted: true, isDisputed: false, contractCID: 'Qm789...' },
        { propertyId: '019', startDate: '2023-04-01', endDate: '2023-09-30', isCompleted: false, isDisputed: true, contractCID: 'Qmabc...' },
        { propertyId: '020', startDate: '2023-05-01', endDate: '2023-08-31', isCompleted: true, isDisputed: false, contractCID: 'Qmdef...' },
        { propertyId: '021', startDate: '2023-06-01', endDate: '2023-07-31', isCompleted: false, isDisputed: true, contractCID: 'Qmghi...' },
        { propertyId: '022', startDate: '2023-07-01', endDate: '2023-06-30', isCompleted: true, isDisputed: false, contractCID: 'Qmjkl...' }
      ],
      currentPage: 1, // 当前页码
      itemsPerPage: 5, // 每页显示的条目数
      contactCurrentPage: 1, // 联系请求当前页码
      rentalCurrentPage: 1, // 租房请求当前页码
      transactionCurrentPage: 1, // 租房交易当前页码
      showTransactionDetails: false, // 控制是否显示交易详情
      selectedTransactionDetails: null // 存储选中的交易详情
    };
  },
  computed: {
    paginatedContactRequests() {
      const start = (this.contactCurrentPage - 1) * this.itemsPerPage;
      const end = start + this.itemsPerPage;
      return this.contactRequests.slice(start, end);
    },
    contactTotalPages() {
      return Math.ceil(this.contactRequests.length / this.itemsPerPage);
    },
    paginatedRentalRequests() {
      const start = (this.rentalCurrentPage - 1) * this.itemsPerPage;
      const end = start + this.itemsPerPage;
      return this.rentalRequests.slice(start, end);
    },
    rentalTotalPages() {
      return Math.ceil(this.rentalRequests.length / this.itemsPerPage);
    },
    paginatedRentalTransactions() {
      const start = (this.transactionCurrentPage - 1) * this.itemsPerPage;
      const end = start + this.itemsPerPage;
      return this.rentalTransactions.slice(start, end);
    },
    transactionTotalPages() {
      return Math.ceil(this.rentalTransactions.length / this.itemsPerPage);
    }
  },
  methods: {
    sendVerificationCode() {
      if (!this.idNumber || !this.phoneNumber) {
        alert('请填写身份证号和手机号');
        return;
      }
      alert('验证码已发送到您的手机');
      this.verificationSent = true;
    },
    verifyIdentity() {
      if (this.verificationCode === '1234') {
        alert('身份认证成功');
        this.isVerified = true;
      } else {
        alert('验证码错误，请重试');
      }
    },
    shortenAddress(address) {
      return address.length > 10 ? `${address.slice(0, 6)}...${address.slice(-4)}` : address;
    },
    viewTransactionDetails(transaction) {
      this.$emit('view-transaction', transaction); // 触发父组件事件
    },
    selectContactRequest(index) {
      this.selectedContactRequest = index;
    },
    selectRentalRequest(index) {
      this.selectedRentalRequest = index;
    },
    selectTransaction(index) {
      this.selectedTransaction = index;
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
    prevContactPage() {
      if (this.contactCurrentPage > 1) {
        this.contactCurrentPage--;
      }
    },
    nextContactPage() {
      if (this.contactCurrentPage < this.contactTotalPages) {
        this.contactCurrentPage++;
      }
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
    prevTransactionPage() {
      if (this.transactionCurrentPage > 1) {
        this.transactionCurrentPage--;
      }
    },
    nextTransactionPage() {
      if (this.transactionCurrentPage < this.transactionTotalPages) {
        this.transactionCurrentPage++;
      }
    }
  }
};
</script>

<style scoped>
.user-info {
  height: 97%; /* 限制整体高度 */
  font-family: 'Cursive', 'Arial', sans-serif;
  padding: 20px;
  background-color: #ffffff;
  border-radius: 8px;
  overflow-y: auto; /* 添加垂直滚动条 */
  display: flex;
  flex-direction: column;
  scrollbar-width: none; /* 隐藏 Firefox 滚动条 */
}

.user-info::-webkit-scrollbar {
  display: none; /* 隐藏 Chrome 和 Safari 滚动条 */
}

.auth-section {
  width: 20%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 50vh; /* 垂直居中 */
  margin: 0 auto; /* 水平居中 */
}

.auth-section label,
.auth-section input {
  display: block;
  margin-bottom: 10px;
}

.auth-section button {
  margin-top: 10px;
  padding: 10px 20px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.auth-section button:hover {
  background-color: #0056b3;
}

.user-details {
  margin-bottom: 20px;
  max-height: none; /* 移除高度限制 */
  overflow-y: visible; /* 移除滚动条 */
}

.requests-container,
.transactions-container {
  margin-bottom: 20px;
  max-height: none; /* 移除高度限制 */
  overflow-y: auto; /* 添加垂直滚动条 */
  scrollbar-width: none; /* 隐藏 Firefox 滚动条 */
}

.requests-container::-webkit-scrollbar,
.transactions-container::-webkit-scrollbar {
  display: none; /* 隐藏 Chrome 和 Safari 滚动条 */
}

.request-box {
  margin-bottom: 20px;
  padding: 10px;
  background-color: rgb(255, 255, 255);
  border: 1px solid #ccc;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  justify-content: space-between; /* 保持内容和分页按钮的间距 */
}

table {
  width: 100%;
  border-collapse: collapse; /* 确保表格边框合并 */
  margin-top: 10px;
  table-layout: fixed; /* 固定表格布局 */
}

th,
td {
  border: 1px solid #ccc;
  padding: 8px;
  text-align: center; /* 居中对齐表项和表格元素 */
  word-wrap: break-word; /* 自动换行，防止内容溢出 */
}

th {
  background-color: #f1f1f1;
  font-weight: bold;
}

th:nth-child(1),
td:nth-child(1) {
  width: 20%; /* 房源编号列宽度 */
}

th:nth-child(2),
td:nth-child(2) {
  width: 30%; /* 接收方地址列宽度 */
}

th:nth-child(3),
td:nth-child(3) {
  width: 30%; /* 发送内容列宽度 */
}

th:nth-child(4),
td:nth-child(4) {
  width: 20%; /* 是否同意列宽度 */
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 10px;
}

.pagination button {
  margin: 0 5px;
  padding: 5px 10px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.pagination button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.pagination span {
  margin: 0 10px;
}

.transactions-container table {
  table-layout: fixed; /* 固定表格布局 */
  width: 100%;
  border-collapse: collapse; /* 确保表格边框合并 */
}

.transactions-container th,
.transactions-container td {
  border: 1px solid #ccc;
  padding: 8px;
  text-align: center; /* 居中对齐表项和表格元素 */
  word-wrap: break-word; /* 自动换行，防止内容溢出 */
  height: 40px; /* 设置固定行高 */
}

.transactions-container th {
  background-color: #f1f1f1;
  font-weight: bold;
}

.transactions-container td {
  vertical-align: middle; /* 垂直居中对齐 */
}

.transactions-container th:nth-child(1),
.transactions-container td:nth-child(1) {
  width: 15%; /* 房产编号列宽度 */
}

.transactions-container th:nth-child(2),
.transactions-container td:nth-child(2) {
  width: 15%; /* 起租时间列宽度 */
}

.transactions-container th:nth-child(3),
.transactions-container td:nth-child(3) {
  width: 15%; /* 结租时间列宽度 */
}

.transactions-container th:nth-child(4),
.transactions-container td:nth-child(4) {
  width: 10%; /* 是否完成列宽度 */
}

.transactions-container th:nth-child(5),
.transactions-container td:nth-child(5) {
  width: 10%; /* 是否纠纷列宽度 */
}

.transactions-container th:nth-child(6),
.transactions-container td:nth-child(6) {
  width: 20%; /* 租房合同列宽度 */
}

.transactions-container th:nth-child(7),
.transactions-container td:nth-child(7) {
  width: 15%; /* 操作列宽度 */
}
</style>
