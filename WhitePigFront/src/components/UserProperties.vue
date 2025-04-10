<template>
  <div class="upload-button-container">
    <button class="upload-button" @click="showUploadModal = true">
      <i class="fas fa-upload"></i> 上传房源
    </button>
  </div>
  <div v-if="showUploadModal" class="modal">
    <div class="modal-content">
      <h3>上传房源信息</h3>
      <form @submit.prevent="submitProperty">
        <label for="monthlyRent">月租金:</label>
        <input type="number" v-model="newProperty.monthlyRent" id="monthlyRent" required />

        <label for="propertyType">房屋类型:</label>
        <select v-model="newProperty.propertyType" id="propertyType" required>
          <option value="一室一厅">一室一厅</option>
          <option value="两室一厅">两室一厅</option>
          <option value="三室一厅">三室一厅</option>
        </select>

        <label for="description">房屋描述:</label>
        <textarea v-model="newProperty.description" id="description" required></textarea>

        <label for="photos">房屋图片:</label>
        <input type="file" @change="handleFileUpload" id="photos" required />

        <label for="location">房屋地址:</label>
        <input type="text" v-model="newProperty.location" id="location" required />

        <button type="submit">提交</button>
        <button type="button" @click="showUploadModal = false">取消</button>
      </form>
    </div>
  </div>
  <div class="user-properties" v-if="showDetailsIndex === null">
    <div v-for="(property, index) in properties" :key="index" class="property-card">
      <img :src="property.image" alt="房源图片" class="property-image" />
      <div class="property-details">
        <p>房源编号: {{ property.id }}</p>
        <p>月租金: ¥{{ property.rent }}</p>
        <p>房屋类型: {{ property.type }}</p>
        <p>描述: {{ property.description }}</p>
        <button @click="toggleDetails(index)">查看详情</button>
      </div>
    </div>
  </div>
  <div v-else>
    <PropertyDetails 
      :property="properties[showDetailsIndex]" 
      @close="closeDetails" 
      :propertyManagementContract="propertyManagementContract" 
      :rentRequestContract="rentRequestContract" 
    />
  </div>
</template>

<script>
import PropertyDetails from './PropertyDetails.vue';

export default {
  name: 'UserProperties',
  components: {
    PropertyDetails
  },
  props: {
    propertyMarketContract: {
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
    },
    walletAddress: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      properties: [],
      showDetailsIndex: null,
      showUploadModal: false,
      newProperty: {
        monthlyRent: '',
        propertyType: '',
        description: '',
        photos: null,
        location: ''
      }
    };
  },
  async created() {
    try {
      const propertyCount = await this.propertyManagementContract.propertyCount();
      const propertiesData = [];

      for (let i = 1; i <= propertyCount; i++) {
        const property = await this.propertyManagementContract.getProperty(i);
        if (property.owner.toLowerCase() === this.walletAddress.toLowerCase()) {
          propertiesData.push({
            id: property.propertyId,
            image: property.photos,
            rent: Number(property.monthlyRent) / 10 ** 18,
            type: property.propertyType,
            description: property.description,
            location: property.location,
            isAvailable: property.isAvailable,
            isWithdraw: property.isWithdraw,
            owner: property.owner
          });
        }
      }

      this.properties = propertiesData;
    } catch (error) {
      console.error('获取房产信息失败:', error);
      alert('无法加载房产信息，请稍后重试');
    }
  },
  methods: {
    toggleDetails(index) {
      this.showDetailsIndex = index;
    },
    closeDetails() {
      this.showDetailsIndex = null;
    },
    handleFileUpload(event) {
      const file = event.target.files[0];
      if (file) {
        const reader = new FileReader();
        reader.onloadend = async () => {
          const cid = await this.uploadToIPFS(file);
          this.newProperty.photos = `http://127.0.0.1:8080/ipfs/${cid}`;
        };
        reader.readAsArrayBuffer(file);
      }
    },
    async uploadToIPFS(file) {
      try {
        const formData = new FormData();
        formData.append('file', file);

        const response = await fetch('http://localhost:5001/api/v0/add', {
          method: 'POST',
          body: formData
        });

        if (!response.ok) {
          throw new Error('IPFS 上传失败');
        }

        const data = await response.json();
        return data.Hash; // 返回文件的 CID
      } catch (error) {
        console.error('IPFS 上传错误:', error);
        throw error;
      }
    },
    async submitProperty() {
      try {
        const { monthlyRent, propertyType, description, photos, location } = this.newProperty;

        // 检查所有字段是否已填写
        if (!monthlyRent || !propertyType || !description || !photos || !location) {
          alert('请完整填写所有房源信息！');
          return;
        }

        console.log('上传的房源信息:', this.newProperty);

        // 将租金转换为精度为 18 的值
        const rentWithPrecision = BigInt(monthlyRent) * BigInt(10 ** 18);

        if (!this.propertyMarketContract || typeof this.propertyMarketContract.addPropertyMarket !== 'function') {
          throw new Error('propertyMarket 未正确传递或方法不存在');
        }

        // 确保所有参数为字符串类型
        await this.propertyMarketContract.addPropertyMarket(
          rentWithPrecision.toString(), // 转换后的租金
          propertyType.toString(),
          description.toString(),
          photos.toString(),
          location.toString()
        );

        alert('房源上传成功！');
        this.showUploadModal = false;
        this.resetForm();
      } catch (error) {
        console.error('上传失败:', error);
        alert(`房源上传失败，请重试！错误信息: ${error.message}`);
      }
    },
    resetForm() {
      this.newProperty = {
        monthlyRent: '',
        propertyType: '',
        description: '',
        photos: null,
        location: ''
      };
    },
    isRentable(id) {
      // 模拟函数，始终返回 true
      return true;
    },
    isRemoved(id) {
      // 模拟函数，始终返回 true
      return true;
    }
  }
};
</script>

<style scoped>
.user-properties {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.property-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  border: none;
  border-radius: 12px;
  padding: 16px;
  background-color: #ffffff;
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.property-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
}

.property-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
  border-radius: 8px;
  margin-bottom: 12px;
}

.property-details {
  display: flex;
  flex-direction: column;
  align-items: flex-start; /* 文字左对齐 */
  font-family: 'Arial', sans-serif;
  padding: 10px; /* 增加内边距 */
}

.property-details p {
  margin: 8px 0;
  font-size: 14px;
  color: #333;
  line-height: 1.6; /* 增加行高，提升可读性 */
}

.property-details button {
  align-self: center; /* 按钮居中 */
  margin-top: 10px;
  padding: 10px 16px;
  font-size: 14px;
  font-weight: bold;
  border: none;
  border-radius: 6px;
  background-color: #ffffff;
  color: #000000;
  cursor: pointer;
  transition: background-color 0.3s ease, transform 0.3s ease, box-shadow 0.3s ease;
}

.property-details button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15); /* 添加阴影效果 */
}

.upload-button-container {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.upload-button {
  margin-bottom: 20px;
  padding: 12px 24px;
  background-color: #f0f0f0; /* 系统默认白色背景 */
  color: #000000; /* 黑色字体 */
  border: 1px solid #ddd;
  border-radius: 25px;
  cursor: pointer;
  font-size: 16px;
  font-weight: bold;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  box-shadow: 0 20px 15px rgba(14, 14, 14, 0.1); /* 添加阴影 */
  transition: all 0.3s ease;
}

.upload-button i {
  font-size: 18px;
}

.upload-button:hover {
  background-color: #f0f0f0; /* 悬停时背景变为浅灰色 */
  transform: translateY(-2px);
  box-shadow: 0 10px 15px rgba(0, 0, 0, 0.15); /* 增强阴影效果 */
}

.modal {
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

.modal-content {
  background-color: #f0f0f0; /* 灰色背景 */
  color: #000000; /* 黑色字体 */
  padding: 20px;
  border-radius: 12px; /* 更圆润的边角 */
  width: 450px;
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2); /* 更高级的阴影效果 */
  font-family: 'Arial', sans-serif;
}

.modal-content h3 {
  margin-top: 0;
  font-size: 20px;
  font-weight: bold;
  text-align: center;
}

.modal-content form {
  display: flex;
  flex-direction: column;
  gap: 15px; /* 增加表单项之间的间距 */
}

.modal-content label {
  font-size: 14px;
  font-weight: bold;
}

.modal-content input,
.modal-content select,
.modal-content textarea {
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 6px;
  font-size: 14px;
  background-color: #ffffff; /* 白色输入框背景 */
  color: #000000; /* 黑色字体 */
}

.modal-content input:focus,
.modal-content select:focus,
.modal-content textarea:focus {
  outline: none;
  border-color: #007bff; /* 聚焦时的边框颜色 */
  box-shadow: 0 0 5px rgba(0, 123, 255, 0.5);
}

.modal-content button {
  padding: 10px;
  font-size: 14px;
  font-weight: bold;
  border: none; /* 移除边框 */
  border-radius: 6px;
  background-color: #f0f0f0; /* 浅灰色背景 */
  color: #000000; /* 黑色字体 */
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* 添加阴影代替边框 */
  transition: all 0.3s ease;
}

.modal-content button:hover {
  background-color: #e0e0e0; /* 悬停时背景变为更深的灰色 */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15); /* 增强悬停时的阴影效果 */
  transform: translateY(-2px); /* 悬停时轻微上移 */
}

.modal-content button[type="submit"] {
  box-shadow: 0 2px 4px rgba(108, 117, 125, 0.3);  /* 提交按钮的阴影颜色 */
}

.modal-content button[type="submit"]:hover {
  background-color: #d6d6d6; /* 提交按钮悬停时的背景颜色 */
}

.modal-content button[type="button"] {
  box-shadow: 0 2px 4px rgba(108, 117, 125, 0.3); /* 取消按钮的阴影颜色 */
}

.modal-content button[type="button"]:hover {
  background-color: #d6d6d6; /* 取消按钮悬停时的背景颜色 */
}

/* 针对关闭、更新下架状态、更新月租金、更新房屋描述按钮的样式 */
.action-button {
  padding: 10px 16px;
  font-size: 14px;
  font-weight: bold;
  border: none; /* 移除边框 */
  border-radius: 6px;
  background-color: #f0f0f0; /* 浅灰色背景 */
  color: #000000; /* 黑色字体 */
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* 添加阴影代替边框 */
  transition: all 0.3s ease;
  margin-top: 10px; /* 增加顶部间距 */
}

.action-button:hover {
  background-color: #e0e0e0; /* 悬停时背景变为更深的灰色 */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15); /* 增强悬停时的阴影效果 */
  transform: translateY(-2px); /* 悬停时轻微上移 */
}
</style>