<template>
  <div class="user-info">
    <!-- 用户身份认证 -->
    <div v-if="!isVerified" class="auth-section">
      <div class="auth-card">
        <h3>身份认证</h3>
        <div class="form-group">
          <label for="id-number">身份证号:</label>
          <input id="id-number" v-model="idNumber" placeholder="请输入身份证号" />
        </div>
        <div class="form-group">
          <label for="phone-number">手机号:</label>
          <input id="phone-number" v-model="phoneNumber" placeholder="请输入手机号" />
        </div>
        <button class="primary-button gradient-button" @click="sendVerificationCode">获取验证码</button>

        <!-- 验证码输入框 -->
        <div v-if="verificationSent" class="form-group">
          <label for="verification-code">验证码:</label>
          <input
            id="verification-code"
            v-model="verificationCode"
            placeholder="请输入验证码"
          />
          <button class="primary-button gradient-button" @click="verifyIdentity">验证身份</button>
        </div>
      </div>
    </div>

    <!-- 用户信息显示 -->
    <div v-else>
      <h2>我的信息</h2>
      <div class="user-details">
        <div class="info-card">
          <i class="icon fas fa-id-card"></i>
          <p class="label"><strong>数字身份证:</strong></p>
          <p class="value">{{ digitalId }}</p>
        </div>
        <div class="info-card">
          <i class="icon fas fa-wallet"></i>
          <p class="label"><strong>钱包地址:</strong></p>
          <p class="value">{{ walletAddress }}</p>
        </div>
        <div class="info-card">
          <i class="icon fas fa-star"></i>
          <p class="label"><strong>信誉积分:</strong></p>
          <p class="value">{{ reputationScore }}</p>
        </div>
        <div class="info-card">
          <i class="icon fas fa-phone"></i>
          <p class="label"><strong>手机号:</strong></p>
          <p class="value">{{ phoneNumber }}</p>
        </div>
        <div class="info-card">
          <i class="icon fas fa-check-circle"></i>
          <p class="label"><strong>身份认证绑定:</strong></p>
          <p class="value">{{ isVerified ? '已绑定' : '未绑定' }}</p>
        </div>
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
                <button 
                  class="view-details-button" 
                  @click.stop="$emit('view-transaction', transaction)"
                >
                  查看详情
                </button>
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
        :currentUserAddress="walletAddress"
        :rentDAOContract = "rentDAOContract"
        :propertyMarketContract = "propertyMarketContract"
      />
    </div>
  </div>
</template>

<script>

export default {
  name: 'UserInfo',
  props: {
    walletAddress: {
      type: String,
      required: true
    },
    userInformationContract: {
      type: Object,
      required: true
    },
    rentRequestContract: {
      type: Object,
      required: true
    },
    rentDAOContract: {
      type: Object,
      required: true
    },
    propertyManagementContract: {
      type: Object,
      required: true
    },
    propertyMarketContract: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      idNumber: '',
      phoneNumber: '',
      verificationCode: '',
      verificationSent: false,
      isVerified: false,
      digitalId: '',
      reputationScore: 0,
      contactRequests: [
        {
          propertyId: '001',
          receiver: '0x1234...abcd',
          content: '希望尽快联系房东。',
          isApproved: false
        }
      ],
      rentalRequests: [
        {
          propertyId: '002',
          receiver: '0x5678...efgh',
          content: '申请租住此房源。',
          isApproved: true
        }
      ],
      rentalTransactions: [
      ],
      currentPage: 1,
      itemsPerPage: 5,
      contactCurrentPage: 1,
      rentalCurrentPage: 1,
      transactionCurrentPage: 1,
      showTransactionDetails: false,
      selectedTransactionDetails: null
    };
  },
  async created() {
    try {
      // 调用 userInformation 合约的 getUserInfo 函数
      const userInfo = await this.userInformationContract.getUserInfo(this.walletAddress);
      this.digitalId = userInfo.idHash;
      this.reputationScore = userInfo.reputation;
      this.phoneNumber = userInfo.number;
      this.isVerified = userInfo.isBound;

      // 调用 rentRequest 合约的 getConRequests 函数
      try {
        const conRequestIds = await this.rentRequestContract.getConRequests(true);
        console.log('获取联系请求 ID 列表:', conRequestIds); // 打印原始返回值

        // 遍历 ID 列表，通过 getConRequestById 获取具体的请求详情
        this.contactRequests = await Promise.all(
          conRequestIds.map(async (id) => {
            const request = await this.rentRequestContract.getConRequestById(id);
            return {
              propertyId: request.propertyId,
              receiver: request.lord,
              content: request.content,
              isApproved: request.approved
            };
          })
        );
      } catch (error) {
        console.error('获取联系请求失败:', error);
      }

      // 调用 rentRequest 合约的 getRentRequests 函数
      try {
        const rentRequestIds = await this.rentRequestContract.getRentRequests(true);
        console.log('获取租房请求 ID 列表:', rentRequestIds); // 打印原始返回值

        // 遍历 ID 列表，通过 getRentRequestById 获取具体的请求详情
        this.rentalRequests = await Promise.all(
          rentRequestIds.map(async (id) => {
            try {
              const request = await this.rentRequestContract.getRentRequestById(id);
              return {
                propertyId: request.propertyId,
                receiver: request.lord,
                content: request.content,
                isApproved: request.approved
              };
            } catch (error) {
              console.warn(`跳过不存在的租房请求 ID: ${id}`, error);
              return null; // 跳过不存在的请求
            }
          })
        );

        // 过滤掉 null 值的请求
        this.rentalRequests = this.rentalRequests.filter(request => request !== null);
      } catch (error) {
        console.error('获取租房请求失败:', error);
      }

      // 调用 rentDAOContract 合约的 dealCount 函数
      const propertyCount = await this.rentDAOContract.dealCount();
      console.log('交易数量:', propertyCount.toNumber()); // 打印交易数量

      // 循环调用 rentDAO 合约的 deals 函数
      for (let i = 0; i < propertyCount.toNumber(); i++) {
        const deal = await this.rentDAOContract.deals(i);
        const isCompleted = await this.propertyMarketContract.checkIsCompleted(deal.propertyId); // 调用 checkIsCompleted 函数
        console.log('交易详情:', deal); // 打印交易详情
        console.log('是否完成:', isCompleted); // 打印是否完成的结果

        if (deal.roomer.toLowerCase() === this.walletAddress.toLowerCase() || deal.landord.toLowerCase() === this.walletAddress.toLowerCase()) {
          this.rentalTransactions.push({
            dealId: i,
            propertyId: deal.propertyId,
            startDate: new Date(deal.rentTimeStart * 1000).toISOString().split('T')[0],
            endDate: new Date(deal.rentTimeEnd * 1000).toISOString().split('T')[0],
            isCompleted: isCompleted, // 使用 checkIsCompleted 的结果
            isDisputed: deal.isDisputed,
            contractCID: deal.rentContract
          });
        }
      }
    } catch (error) {
      console.error('加载用户信息失败:', error);
    }
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
      this.verificationSent = true; // 确保状态更新，显示验证码输入框
      console.log('验证码已发送到手机:', this.verificationSent); // 添加调试日志
    },
    async verifyIdentity() {
      if (!this.verificationCode) {
        alert('请输入验证码');
        return;
      }
      try {
        const tx = await this.userInformationContract.verify(this.idNumber, this.phoneNumber);
        await tx.wait(); // 等待交易完成
        console.log('身份认证交易已完成:', tx);
        alert('身份认证成功');
        this.isVerified = true;
      } catch (error) {
        console.error('身份认证失败:', error);
        alert('身份认证失败，请重试');
      }
    },
    shortenAddress(address) {
      if (!address) {
        return '未知地址'; // 如果地址为 undefined 或 null，返回默认值
      }
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
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh; /* 全屏高度 */
}

.auth-card {
  background: linear-gradient(145deg, #ffffff, #f0f0f0);
  padding: 30px;
  border-radius: 16px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15); /* 更柔和的阴影 */
  width: 450px;
  text-align: center;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.auth-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2); /* 悬停时的阴影效果 */
}

.auth-card h3 {
  margin-bottom: 20px;
  font-size: 26px;
  color: #333;
  font-weight: bold;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.auth-card button {
  margin-top: 25px; /* 增加按钮与上方元素的间距 */
}

.form-group {
  margin-bottom: 25px; /* 增加底部间距 */
  text-align: left;
  position: relative; /* 确保子元素可以定位 */
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  color: #555;
}

.form-group input {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 16px;
  box-sizing: border-box;
  transition: border-color 0.3s ease, box-shadow 0.3s ease;
}

.form-group input:focus {
  border-color: #4b4e55;
  box-shadow: 0 0 8px rgba(75, 78, 85, 0.3);
  outline: none;
}

#verification-code {
  margin-top: 20px; /* 增加顶部间距 */
}

.primary-button {
  width: 100%;
  padding: 10px 20px;
  color: black; /* 设置字体颜色为黑色 */
  border: none;
  border-radius: 6px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: transform 0.2s ease;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 添加阴影 */
}

.primary-button:hover {
  transform: scale(1.05); /* 添加缩放效果 */
}

.primary-button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.gradient-button {
  color: black; /* 设置字体颜色为黑色 */
  border: none;
  border-radius: 8px;
  font-size: 18px;
  font-weight: bold;
  cursor: pointer;
  padding: 12px 24px;
  transition: transform 0.2s ease;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 添加阴影 */
}

.gradient-button:hover {
  transform: scale(1.05); /* 添加缩放效果 */
}

.gradient-button:disabled {
  background: #ccc;
  cursor: not-allowed;
}

button.view-details-button {
  padding: 10px 20px;
  font-size: 14px;
  border: none; /* 移除边框 */
  border-radius: 6px; /* 圆角 */
  background-color: #ffffff; /* 白色背景 */
  color: #000; /* 黑色字体 */
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* 添加阴影 */
  transition: all 0.3s ease;
}

button.view-details-button:hover {
  background-color: #f0f0f0; /* 悬停时浅灰色背景 */
  transform: translateY(-2px); /* 悬停时轻微上移 */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15); /* 增强阴影效果 */
}

.user-details {
  width: 97%;
  display: flex;
  flex-direction: column; /* 改为纵向排列 */
  gap: 15px; /* 卡片之间的间距 */
}

.info-card {
  width: 100%; /* 占满整行 */
  word-wrap: break-word; /* 自动换行，防止内容溢出 */
  background-color: #e0e0e07c;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between; /* 图标、标签和值两端对齐 */
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.info-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.2);
}

.info-card .icon {
  font-size: 24px;
  color: #4b4e55;
  margin-right: 15px;
}

.info-card .label {
  flex-grow: 1; /* 占据剩余空间 */
  text-align: left; /* 标签左对齐 */
}

.info-card .value {
  text-align: right; /* 值右对齐 */
  font-weight: bold; /* 加粗值 */
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
  border-collapse: collapse; /* 合并边框 */
  margin-top: 15px;
  background-color: #ffffff; /* 白色背景 */
  border-radius: 8px; /* 圆角 */
  overflow: hidden; /* 隐藏溢出 */
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); /* 添加阴影 */
}

th {
  background-color: #f9f9f9; /* 浅灰色背景 */
  font-weight: bold;
  color: #000; /* 黑色字体 */
  padding: 12px;
  text-align: center;
  border-bottom: 1px solid #ddd; /* 添加底部边框 */
}

td {
  padding: 12px;
  text-align: center;
  color: #333; /* 深灰色字体 */
  border-bottom: 1px solid #f0f0f0; /* 添加底部边框 */
}

tr:last-child td {
  border-bottom: none; /* 移除最后一行的底部边框 */
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 15px;
  gap: 10px; /* 增加按钮间距 */
}

.pagination button {
  padding: 8px 16px;
  font-size: 14px;
  border: none; /* 移除边框 */
  border-radius: 6px; /* 圆角 */
  background-color: #ffffff; /* 白色背景 */
  color: #000; /* 黑色字体 */
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* 添加阴影 */
  transition: all 0.3s ease;
}

.pagination button:hover {
  background-color: #f0f0f0; /* 悬停时浅灰色背景 */
  transform: translateY(-2px); /* 悬停时轻微上移 */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15); /* 增强阴影效果 */
}

.pagination button:disabled {
  background-color: #e0e0e0; /* 禁用按钮灰色背景 */
  color: #999; /* 禁用按钮灰色字体 */
  cursor: not-allowed;
}

.transactions-container table {
  width: 100%;
  border-collapse: collapse; /* 合并边框 */
  margin-top: 15px;
  background-color: #ffffff; /* 白色背景 */
  border-radius: 8px; /* 圆角 */
  overflow: hidden; /* 隐藏溢出 */
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); /* 添加阴影 */
}

.transactions-container th {
  background-color: #f9f9f9; /* 浅灰色背景 */
  font-weight: bold;
  color: #000; /* 黑色字体 */
  padding: 12px;
  text-align: center;
  border-bottom: 1px solid #ddd; /* 添加底部边框 */
}

.transactions-container td {
  padding: 12px;
  text-align: center;
  color: #333; /* 深灰色字体 */
  border-bottom: 1px solid #f0f0f0; /* 添加底部边框 */
}

.transactions-container tr:last-child td {
  border-bottom: none; /* 移除最后一行的底部边框 */
}

.transactions-container button.view-details-button {
  padding: 10px 20px;
  font-size: 14px;
  border: none; /* 移除边框 */
  border-radius: 6px; /* 圆角 */
  background-color: #ffffff; /* 白色背景 */
  color: #000; /* 黑色字体 */
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* 添加阴影 */
  transition: all 0.3s ease;
}

.transactions-container button.view-details-button:hover {
  background-color: #f0f0f0; /* 悬停时浅灰色背景 */
  transform: translateY(-2px); /* 悬停时轻微上移 */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15); /* 增强阴影效果 */
}

.transactions-container .pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 15px;
  gap: 10px; /* 增加按钮间距 */
}

.transactions-container .pagination button {
  padding: 8px 16px;
  font-size: 14px;
  border: none; /* 移除边框 */
  border-radius: 6px; /* 圆角 */
  background-color: #ffffff; /* 白色背景 */
  color: #000; /* 黑色字体 */
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* 添加阴影 */
  transition: all 0.3s ease;
}

.transactions-container .pagination button:hover {
  background-color: #f0f0f0; /* 悬停时浅灰色背景 */
  transform: translateY(-2px); /* 悬停时轻微上移 */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15); /* 增强阴影效果 */
}

.transactions-container .pagination button:disabled {
  background-color: #e0e0e0; /* 禁用按钮灰色背景 */
  color: #999; /* 禁用按钮灰色字体 */
  cursor: not-allowed;
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

h2, h3 {
  font-size: 24px; /* 设置统一的字体大小 */
  font-weight: bold; /* 加粗 */
  color: #333; /* 设置颜色 */
  margin-bottom: 15px; /* 添加底部间距 */
}
</style>
