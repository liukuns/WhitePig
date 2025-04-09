<template>
  <h2>用户房产信息</h2>
  <button class="upload-button" @click="showUploadModal = true">上传房源</button>
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
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  font-family: 'Cursive', 'Arial', sans-serif;
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.property-card {
  flex: 0 0 calc(33.33% - 10px);
  margin: 10px 5px;
  display: flex;
  flex-direction: column;
  align-items: center;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 16px;
  margin-top: 20px;
  background-color: #fff;
  max-width: 300px;
  width: 100%;
  margin: 10px auto;
  box-sizing: border-box;
}

.user-properties::after {
  content: '';
  flex: auto;
}

.property-image {
  width: 100%;
  height: auto;
  border-radius: 8px;
}

.property-details {
  margin-top: 12px;
  text-align: center;
}

button {
  margin-top: 10px;
  padding: 8px 16px;
  background-color: #000000;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:hover {
  background-color: #0056b3;
}

.upload-button {
  margin-bottom: 20px;
  padding: 10px 20px;
  background-color: #000000;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.upload-button:hover {
  background-color: #218838;
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
  background-color: #fff;
  padding: 20px;
  border-radius: 8px;
  width: 400px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.modal-content h3 {
  margin-top: 0;
}

.modal-content form {
  display: flex;
  flex-direction: column;
}

.modal-content label {
  margin-top: 10px;
}

.modal-content input,
.modal-content select,
.modal-content textarea {
  margin-top: 5px;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.modal-content button {
  margin-top: 15px;
  padding: 10px;
  background-color: #007bff;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.modal-content button:hover {
  background-color: #0056b3;
}

.modal-content button[type="button"] {
  background-color: #6c757d;
}

.modal-content button[type="button"]:hover {
  background-color: #5a6268;
}
</style>