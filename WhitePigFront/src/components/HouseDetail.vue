<template>
  <div class="house-details">
    <button @click="$emit('go-back')">返回</button>

    <!-- 图片轮播 -->
    <div class="image-carousel">
      <button class="carousel-arrow left" @click="prevImage">←</button>
      <img :src="currentImage" alt="房屋图片" />
      <button class="carousel-arrow right" @click="nextImage">→</button>
    </div>

    <!-- 房屋详情介绍 -->
    <div class="details-section">
      <h2>房屋详情</h2>
      <p><span class="label">位置:</span><span class="value">{{ house.location }}</span></p>
      <p><span class="label">描述:</span><span class="value">{{ house.description }}</span></p>
      <p><span class="label">型号:</span><span class="value">{{ house.type }}</span></p>
      <p><span class="label">价格:</span><span class="value">{{ house.rent }} RMB/月</span></p>
      <p><span class="label">房东信誉值:</span><span class="value">{{ landlordReputation }}</span></p>
      <p><span class="label">房东钱包地址:</span><span class="value">{{ house.owner }}</span></p>
    </div> 

    <!-- 功能按钮 -->
    <div class="action-buttons">
      <button @click="openContactModal">交换联系方式</button>
      <button @click="openRentalModal">线下预约看房</button>
      <button @click="openTransactionModal">合约存放凭证</button>
    </div>

    <!-- 房源历史评价 -->
    <div class="history-section">
      <h3>房源历史评价</h3>
      <ul>
        <li v-for="(review, index) in houseReviews" :key="index">
          {{ review }}
        </li>
      </ul>
    </div>

    <div v-if="showContactModal" class="modal-overlay">
      <div class="modal">
        <h3>发送租房联系请求</h3>
        <textarea v-model="contactMessage" placeholder="请输入联系信息"></textarea>
        <div class="modal-buttons">
          <button @click="sendContactRequest">发送</button>
          <button @click="closeContactModal">取消</button>
        </div>
      </div>
    </div>

    <div v-if="showRentalModal" class="modal-overlay">
      <div class="modal">
        <h3>提交租房申请</h3>
        <textarea v-model="rentalMessage" placeholder="请输入申请信息"></textarea>
        <div class="modal-buttons">
          <button @click="sendRentalRequest">提交</button>
          <button @click="closeRentalModal">取消</button>
        </div>
      </div>
    </div>

    <div v-if="showTransactionModal" class="modal-overlay">
      <div class="modal">
        <h3>提交租房交易</h3>
        <input type="number" v-model="rentalMonths" placeholder="请输入租的月份" />
        <input type="file" @change="handleFileUpload" />
        <div class="modal-buttons">
          <button @click="submitTransaction">提交</button>
          <button @click="closeTransactionModal">取消</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { create } from 'ipfs-http-client';

export default {
  name: 'HouseDetails',
  props: {
    house: {
      type: Object,
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
    },
    usdtContract: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      images: [], // 初始化为空数组
      currentImageIndex: 0,
      landlordReputation: 0,
      houseReviews: [
        '房子很干净，房东很友好。',
        '位置很好，交通便利。',
        '设施齐全，性价比高。'
      ],
      showContactModal: false,
      contactMessage: '',
      showRentalModal: false,
      rentalMessage: '',
      showTransactionModal: false,
      rentalMonths: '',
      contractFile: null,
      ipfsClient: null // IPFS 客户端实例
    };
  },
  computed: {
    currentImage() {
      return this.images[this.currentImageIndex];
    }
  },
  async created() {
    try {
      // 调用合约获取房东信誉值
      this.landlordReputation = await this.userInformationContract.getUserReputation(this.house.owner);

      // 设置图片轮播内容为 house.photos
      this.images = this.house.image.split(','); // 假设 house.photos 是逗号分隔的字符串
      console.log('房屋图片:', this.images);
    } catch (error) {
      console.error('初始化失败:', error);
      alert('无法加载房屋详情，请稍后重试');
    }

    // 初始化 IPFS 客户端
    this.ipfsClient = create({
      url: 'http://127.0.0.1:5001/api/v0'
    });
  },
  methods: {
    prevImage() {
      this.currentImageIndex =
        (this.currentImageIndex - 1 + this.images.length) % this.images.length; // 切换到上一张图片
    },
    nextImage() {
      this.currentImageIndex =
        (this.currentImageIndex + 1) % this.images.length; // 切换到下一张图片
    },
    openContactModal() {
      this.showContactModal = true; // 打开弹窗
    },
    closeContactModal() {
      this.showContactModal = false; // 关闭弹窗
      this.contactMessage = ''; // 清空输入框
    },
    async sendContactRequest() {
      if (this.contactMessage.trim() === '') {
        alert('请输入信息后再发送');
        return;
      }
      try {
        await this.rentRequestContract.sendConRequest(this.house.id, this.contactMessage);
        alert('租房联系请求已发送！');
      } catch (error) {
        console.error('发送租房联系请求失败:', error);
        alert('发送失败，请稍后重试！');
      } finally {
        this.closeContactModal(); // 发送后关闭弹窗
      }
    },
    openRentalModal() {
      this.showRentalModal = true; // 打开租房申请弹窗
    },
    closeRentalModal() {
      this.showRentalModal = false; // 关闭租房申请弹窗
      this.rentalMessage = ''; // 清空输入框
    },
    async sendRentalRequest() {
      if (this.rentalMessage.trim() === '') {
        alert('请输入申请信息后再提交');
        return;
      }
      try {
        await this.rentRequestContract.sendRentRequest(this.house.id, this.rentalMessage);
        alert('租房申请已提交！');
      } catch (error) {
        console.error('提交租房申请失败:', error);
        alert('提交失败，请稍后重试！');
      } finally {
        this.closeRentalModal(); // 提交后关闭弹窗
      }
    },
    openTransactionModal() {
      this.showTransactionModal = true; // 打开租房交易弹窗
    },
    closeTransactionModal() {
      this.showTransactionModal = false; // 关闭租房交易弹窗
      this.rentalMonths = ''; // 清空租的月份
      this.contractFile = null; // 清空上传的文件
    },
    handleFileUpload(event) {
      this.contractFile = event.target.files[0]; // 获取上传的文件
    },
    async submitTransaction() {
      if (!this.rentalMonths || !this.contractFile) {
        alert('请填写租的月份并上传租房合同');
        return;
      }

      try {
        // 计算租房所需金额并提高 18 个精度，转换为字符串
        const totalAmount = (this.house.rent * this.rentalMonths * (10 ** 18)).toLocaleString('fullwide', { useGrouping: false });
        console.log(`租房金额: ${totalAmount}`, this.house.rent, this.rentalMonths);

        // 调用 USDT 合约的 transfer 方法，设置更高的 gas 上限
        const propertyMarketAddress = this.propertyMarketContract.address;
        try {
          await this.usdtContract.transfer(propertyMarketAddress, totalAmount, {
            gasLimit: 3000000 // 明确指定更高的 gas 上限
          });
          console.log(`USDT 转账成功: ${totalAmount} 转给 ${propertyMarketAddress}`);
        } catch (transferError) {
          console.error('USDT 转账失败:', transferError);
          alert('USDT 转账失败，请检查余额或稍后重试');
          return;
        }

        // 上传文件到 IPFS
        const added = await this.ipfsClient.add(this.contractFile);
        const ipfsLink = `http://127.0.0.1:8080/ipfs/${added.path}`; // 本地 IPFS 网关地址

        console.log(this.propertyMarketContract);

        // 调用合约的 rent 函数
        try {
          await this.propertyMarketContract.rent(this.house.id, this.rentalMonths, ipfsLink, {
            gasLimit: 3000000 // 明确指定更高的 gas 上限
          });
          alert(`租房交易已提交: 月份=${this.rentalMonths}, 合同链接=${ipfsLink}`);
          this.closeTransactionModal();
        } catch (rentError) {
          console.error('调用 rent 函数失败:', rentError);
          alert('租房交易提交失败，请稍后重试');
        }
      } catch (error) {
        console.error('租房交易提交失败:', error);
        alert('提交失败，请稍后重试');
      }
    }
  }
};
</script>

<style scoped>
.house-details {
  font-family: 'Cursive', 'Arial', sans-serif;
  padding: 20px;
  border-radius: 8px;
  max-height: 90vh;
  overflow-y: auto;
  scrollbar-width: none; /* 隐藏滚动条 */
}

.house-details::-webkit-scrollbar {
  display: none; /* 隐藏滚动条 */
}

.details-section p {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
}

.details-section p span {
  flex: 1;
  text-align: left;
}

.details-section p span.value {
  text-align: right;
}

button {
  margin-bottom: 20px;
  padding: 12px 24px;
  color: rgb(0, 0, 0);
  border: none;
  border-radius: 8px; /* 圆角更大 */
  cursor: pointer;
  font-size: 16px; /* 增大字体 */
  font-weight: bold; /* 加粗字体 */
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 添加阴影 */
  transition: transform 0.3s, background 0.3s, box-shadow 0.3s; /* 添加过渡效果 */
}

button:hover {
  transform: translateY(-2px); /* 悬停时上移 */
  box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15); /* 悬停时阴影加深 */
}

button:active {
  transform: translateY(0); /* 点击时恢复原位 */
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 点击时阴影恢复 */
}

.image-carousel {
  position: relative; /* 设置为相对定位以便定位箭头 */
  width: 50%; /* 调整宽度为50% */
  margin: 0 auto; /* 居中对齐 */
  text-align: center;
  margin-bottom: 20px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* 添加阴影效果 */
  border-radius: 8px;
  overflow: hidden; /* 确保图片不会超出边界 */
}

.image-carousel img {
  width: 100%;
  max-height: 400px; /* 增加最大高度 */
  object-fit: cover;
}

.carousel-arrow {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: none; /* 移除背景 */
  color: black; /* 设置为黑色 */
  border: none; /* 移除边框 */
  font-size: 24px; /* 调整字体大小 */
  cursor: pointer;
  z-index: 1;
}

.carousel-arrow.left {
  left: 10px; /* 左箭头位置 */
}

.carousel-arrow.right {
  right: 10px; /* 右箭头位置 */
}

.details-section {
  margin-bottom: 20px;
}

.action-buttons {
  display: flex;
  gap: 10px;
}

.action-buttons button {
  flex: 1;
}

.history-section {
  margin-top: 20px;
  padding: 10px;
  background-color: #f1f1f1;
  border-radius: 8px;
}

.history-section h3 {
  margin-bottom: 10px;
  color: #60666c;
}

.history-section ul {
  list-style-type: disc;
  padding-left: 20px;
}

.history-section li {
  margin-bottom: 5px;
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
}

.modal {
  background: linear-gradient(135deg, #ffffff, #f9f9f9); /* 弹窗渐变背景 */
  padding: 30px; /* 增加内边距 */
  border-radius: 12px; /* 更大的圆角 */
  width: 450px; /* 增加宽度 */
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2); /* 更深的阴影 */
  display: flex; /* 使用 flex 布局 */
  flex-direction: column; /* 垂直排列 */
  align-items: center; /* 水平居中 */
  justify-content: center; /* 垂直居中 */
}

.modal textarea,
.modal input[type="number"],
.modal input[type="file"] {
  width: 100%; /* 占满宽度 */
  margin-bottom: 10px; /* 调整下方间距 */
  padding: 8px; /* 减少内边距 */
  border: 1px solid #ccc; /* 边框颜色 */
  border-radius: 4px; /* 减小圆角 */
  font-size: 14px; /* 调整字体大小 */
  box-shadow: none; /* 移除阴影 */
  transition: border-color 0.2s; /* 简化过渡效果 */
  text-align: left; /* 确保文本左对齐 */
}

.modal textarea:focus,
.modal input[type="number"]:focus,
.modal input[type="file"]:focus {
  border-color: #999; /* 聚焦时边框颜色 */
  outline: none; /* 移除默认聚焦样式 */
}

.modal input[type="file"]::file-selector-button {
  color: rgb(147, 147, 147);
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  cursor: pointer;
  font-size: 14px;
  transition: background 0.3s, transform 0.3s;
}

.modal input[type="file"]::file-selector-button:hover {
  transform: scale(1.05); /* 悬停时放大 */
}

.modal-buttons {
  display: flex;
  justify-content: space-between;
  gap: 10px; /* 增加按钮间距 */
  margin-top: 20px; /* 增加顶部间距 */
  width: 100%; /* 按钮占满宽度 */
}

.modal-buttons button {
  padding: 12px 24px;
  border: none;
  border-radius: 8px; /* 圆角更大 */
  cursor: pointer;
  font-size: 16px; /* 增大字体 */
  font-weight: bold; /* 加粗字体 */
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 添加阴影 */
  transition: transform 0.3s, background 0.3s, box-shadow 0.3s; /* 添加过渡效果 */
}

.modal-buttons button:first-child {
  color: rgb(0, 0, 0);
}

.modal-buttons button:last-child {
  color: rgb(0, 0, 0);
}

.modal-buttons button:hover {
  transform: translateY(-2px); /* 悬停时上移 */
  box-shadow: 0 6px 10px rgba(0, 0, 0, 0.15); /* 悬停时阴影加深 */
}

.modal-buttons button:active {
  transform: translateY(0); /* 点击时恢复原位 */
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 点击时阴影恢复 */
}
</style>
