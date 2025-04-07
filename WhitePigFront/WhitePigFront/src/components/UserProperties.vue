<template>
  <h2>用户房产信息</h2>
  <div class="user-properties" v-if="showDetailsIndex === null">
    <div v-for="(property, index) in properties" :key="index" class="property-card">
      <img :src="property.image" alt="房源图片" class="property-image" />
      <div class="property-details">
        <p>房源编号: {{ property.id }}</p>
        <p>月租金: ¥{{ property.rent }}</p>
        <p>房屋类型: {{ property.type }}</p>
        <p>是否可租: {{ isRentable(property.id) ? '是' : '否' }}</p>
        <p>是否下架: {{ isRemoved(property.id) ? '是' : '否' }}</p>
        <button @click="toggleDetails(index)">查看详情</button>
      </div>
    </div>
  </div>
  <div v-else>
    <PropertyDetails :property="properties[showDetailsIndex]" @close="closeDetails" />
  </div>
</template>

<script>
import PropertyDetails from './PropertyDetails.vue';

export default {
  name: 'UserProperties',
  components: {
    PropertyDetails
  },
  data() {
    return {
      properties: [
        {
          id: '001',
          image: '/path/to/image1.jpg',
          rent: 3000,
          type: '两室一厅'
        },
        {
          id: '002',
          image: '/path/to/image2.jpg',
          rent: 4500,
          type: '三室两厅'
        },
        {
          id: '003',
          image: '/path/to/image3.jpg',
          rent: 2500,
          type: '一室一厅'
        },
        {
          id: '004',
          image: '/path/to/image4.jpg',
          rent: 6000,
          type: '四室两厅'
        },
        {
          id: '005',
          image: '/path/to/image5.jpg',
          rent: 3500,
          type: '两室一厅'
        },
        {
          id: '006',
          image: '/path/to/image6.jpg',
          rent: 5000,
          type: '三室一厅'
        },
        {
          id: '007',
          image: '/path/to/image7.jpg',
          rent: 7000,
          type: '四室三厅'
        },
        {
          id: '008',
          image: '/path/to/image8.jpg',
          rent: 2800,
          type: '一室一厅'
        },
        {
          id: '009',
          image: '/path/to/image9.jpg',
          rent: 4000,
          type: '两室两厅'
        }
      ],
      showDetailsIndex: null
    };
  },
  methods: {
    toggleDetails(index) {
      this.showDetailsIndex = index;
    },
    closeDetails() {
      this.showDetailsIndex = null;
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
  background-color: #007bff;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

button:hover {
  background-color: #0056b3;
}
</style>