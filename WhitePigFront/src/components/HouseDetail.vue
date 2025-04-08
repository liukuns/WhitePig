<template>
  <div class="house-details">
    <button @click="$emit('go-back')">返回</button>

    <!-- 图片轮播 -->
    <div class="image-carousel">
      <img :src="currentImage" alt="房屋图片" />
      <div class="carousel-controls">
        <button @click="prevImage">上一张</button>
        <button @click="nextImage">下一张</button>
      </div>
    </div>

    <!-- 房屋详情介绍 -->
    <div class="details-section">
      <h2>房屋详情</h2>
      <p><span class="label">位置:</span><span class="value">{{ house.location }}</span></p>
      <p><span class="label">描述:</span><span class="value">{{ house.description }}</span></p>
      <p><span class="label">型号:</span><span class="value">{{ house.type }}</span></p>
      <p><span class="label">房东信誉值:</span><span class="value">{{ landlordReputation }}</span></p>
      <p><span class="label">房东钱包地址:</span><span class="value">{{ house.owner }}</span></p>
    </div> 

    <!-- 功能按钮 -->
    <div class="action-buttons">
      <button @click="openContactModal">租房联系请求</button>
      <button @click="openRentalModal">租房申请</button>
      <button @click="openTransactionModal">租房交易</button>
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
        // 计算租房所需金额
        const totalAmount = this.house.rent * this.rentalMonths;

        console.log(this.usdtContract);

        // 调用 USDT 合约的 transfer 方法，设置更高的 gas 上限
        const propertyMarketAddress = this.propertyMarketContract.address;
        await this.usdtContract.transfer(propertyMarketAddress, totalAmount, {
          gasLimit: 100000 // 提高 gas 上限
        });
        console.log(`USDT 转账成功: ${totalAmount} 转给 ${propertyMarketAddress}`);

        // 上传文件到 IPFS
        const added = await this.ipfsClient.add(this.contractFile);
        const ipfsLink = `http://127.0.0.1:8080/ipfs/${added.path}`; // 本地 IPFS 网关地址

        console.log(this.propertyMarketContract);

        // 调用合约的 rent 函数
        await this.propertyMarketContract.rent(this.house.id, this.rentalMonths, ipfsLink);
        alert(`租房交易已提交: 月份=${this.rentalMonths}, 合同链接=${ipfsLink}`);
        this.closeTransactionModal();
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
  background-color: #f9f9f9;
  border-radius: 8px;
}

.details-section p {
  display: flex;
  justify-content: space-between; /* 调整为两端对齐 */
  margin-bottom: 10px;
}

.details-section p span {
  flex: 1;
  text-align: left; /* 左对齐标签 */
}

.details-section p span.value {
  text-align: right; /* 右对齐值 */
}

button {
  margin-bottom: 20px;
  padding: 10px 20px;
  background-color: #000000;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.image-carousel {
  text-align: center;
  margin-bottom: 20px;
}

.image-carousel img {
  width: 100%;
  max-height: 300px;
  border-radius: 8px;
  object-fit: cover;
}

.carousel-controls {
  margin-top: 10px;
}

.carousel-controls button {
  margin: 0 5px;
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
  width: 95%; /* 调整宽度为90%，避免超出边界 */
  height: 100px;
  margin-bottom: 10px;
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 4px;
  resize: none;
}

.modal input[type="number"],
.modal input[type="file"] {
  width: 95%; /* 确保宽度适配弹窗 */
  margin-bottom: 10px;
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.modal input[type="file"]::file-selector-button {
  color: #aaa; /* 修改未选择文件的字体颜色为淡灰色 */
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
  background-color: #000000;
  color: white;
}

.modal-buttons button:last-child {
  background-color: #ccc;
  color: black;
}
</style>
