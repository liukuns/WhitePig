<template>
  <div class="rental-market">
    <div v-if="!showDetails">
      <div class="search-bar">
        <div id="location-filter">
          <label for="location">位置:</label>
          <select id="location" v-model="filters.location">
            <option value="jinjiang">锦江区</option>
            <option value="qingyang">青羊区</option>
            <option value="wuhou">武侯区</option>
            <option value="chenghua">成华区</option>
          </select>
        </div>

        <div class="vertical-line"></div> <!-- 添加竖线 -->

        <div id="price-filter">
          <label for="price">价格(RMB):</label>
          <input
            type="range"
            id="price"
            v-model="filters.price"
            :min="priceRange.min"
            :max="priceRange.max"
            step="100"
          />
          <span>{{ filters.price }} RMB</span>
        </div>

        <div class="vertical-line"></div> <!-- 添加竖线 -->

        <div id="type-filter">
          <label for="type">房屋型号</label>
          <select id="type" v-model="filters.type">
            <option value="1">一室一厅</option>
            <option value="2">两室一厅</option>
            <option value="3">三室一厅</option>
          </select>
        </div>

        <button @click="search" id="search-btn"><strong>搜索</strong></button>
      </div>

      <div class="divider"></div>

      <div class="house-cards">
        <div 
          v-for="house in houses" 
          :key="house.id" 
          class="house-card" 
          @click="viewDetails(house)"
        >
          <img :src="house.image" alt="房屋图片" />
          <h3>{{ house.location }}</h3>
          <p>{{ house.description }}</p>
          <p>型号: {{ house.type }}</p>
        </div>
      </div>
    </div>

    <HouseDetail
      v-else 
      :house="selectedHouse" 
      @go-back="showDetails = false"
    />
  </div>
</template>

<script>
import HouseDetail from './HouseDetail.vue';

export default {
  name: 'RentalMarket',
  components: {
    HouseDetail
  },
  data() {
    return {
      filters: {
        location: '',
        price: 1000,
        type: ''
      },
      priceRange: {
        min: 0,
        max: 10000
      },
      houses: [
        {
          id: 1,
          image: 'house1.jpg',
          location: '锦江区',
          description: '靠近地铁，交通便利。',
          type: '一室一厅'
        },
        {
          id: 2,
          image: 'house2.jpg',
          location: '青羊区',
          description: '环境优美，设施齐全。',
          type: '两室一厅'
        },
        {
          id: 3,
          image: 'house3.jpg',
          location: '武侯区',
          description: '适合家庭居住，周边配套完善。',
          type: '三室一厅'
        },
        {
          id: 4,
          image: 'house4.jpg',
          location: '成华区',
          description: '新装修，拎包入住。',
          type: '一室一厅'
        },
        {
          id: 5,
          image: 'house5.jpg',
          location: '锦江区',
          description: '靠近商圈，生活便利。',
          type: '两室一厅'
        },
        {
          id: 6,
          image: 'house6.jpg',
          location: '青羊区',
          description: '安静舒适，适合居住。',
          type: '三室一厅'
        },
        {
          id: 7,
          image: 'house7.jpg',
          location: '武侯区',
          description: '交通便利，生活方便。',
          type: '一室一厅'
        },
        {
          id: 8,
          image: 'house8.jpg',
          location: '成华区',
          description: '新装修，拎包入住。',
          type: '两室一厅'
        },
        {
          id: 9,
          image: 'house9.jpg',
          location: '锦江区',
          description: '靠近商圈，生活便利。',
          type: '三室一厅'
        },
        {
          id: 10,
          image: 'house10.jpg',
          location: '青羊区',
          description: '安静舒适，适合居住。',
          type: '一室一厅'
        },
        {
          id: 11,
          image: 'house11.jpg',
          location: '武侯区',
          description: '交通便利，生活方便。',
          type: '两室一厅'
        },
        {
          id: 12,
          image: 'house12.jpg',
          location: '成华区',
          description: '新装修，拎包入住。',
          type: '三室一厅'
        },
        {
          id: 13,
          image: 'house13.jpg',
          location: '锦江区',
          description: '靠近商圈，生活便利。',
          type: '一室一厅'
        },
        {
          id: 14,
          image: 'house14.jpg',
          location: '青羊区',
          description: '安静舒适，适合居住。',
          type: '两室一厅'
        },
        {
          id: 15,
          image: 'house15.jpg',
          location: '武侯区',
          description: '交通便利，生活方便。',
          type: '三室一厅'
        },
        {
          id: 16,
          image: 'house16.jpg',
          location: '成华区',
          description: '新装修，拎包入住。',
          type: '一室一厅'
        }
      ],
      showDetails: false, // 控制是否显示房屋详情
      selectedHouse: null, // 存储选中的房屋信息
      rentalRequests: [
        {
          propertyId: 1,
          sender: '0x123',
          content: '请求租房',
          isApproved: false
        },
        {
          propertyId: 2,
          sender: '0x456',
          content: '请求租房',
          isApproved: true
        }
      ]
    };
  },
  methods: {
    search() {
      alert(`搜索条件: 位置=${this.filters.location}, 价格=${this.filters.price}, 型号=${this.filters.type}`);
    },
    viewDetails(house) {
      this.selectedHouse = house; // 设置选中的房屋信息
      this.showDetails = true; // 切换到房屋详情视图
    },
    handleRentalRequest(request) {
      request.isApproved = !request.isApproved;
    }
  }
};
</script>

<style scoped>
.rental-market {
  background-color: #ffffff;
  border-radius: 8px;
  height: 103%; /* 确保盒子高度占满父容器 */
  display: flex;
  flex-direction: column;
  overflow: hidden; /* 防止内容溢出盒子 */
}

.search-bar {
  display: flex;
  align-items: center; /* 垂直居中对齐 */
}

#location-filter {
  width: 8%;
  background: #ffffff;
  color: rgb(0, 0, 0); /* 白色文字 */
  padding: 10px; /* 内边距 */
}

#price-filter {
  width: 25%;
  background: #ffffff;
  color: rgb(0, 0, 0); /* 白色文字 */
  padding: 10px; /* 内边距 */
}

#type-filter {
  width: 12%;
  background: #ffffff;
  color: rgb(0, 0, 0); /* 白色文字 */
  padding: 10px; /* 内边距 */
}

.vertical-line {
  width: 2px;
  height: 30px; /* 设置竖线高度 */
  background-color: #b2a9a9; /* 黑色竖线 */
  margin: 0 10px; /* 设置竖线与两侧盒子的间距 */
}

#search-btn {
  width: 5%;
  background: #ffffff;
  color: rgb(0, 0, 0); /* 白色文字 */
  padding: 10px; /* 内边距 */
  border: none; /* 去掉边框 */
  cursor: pointer; /* 鼠标悬停时显示手型光标 */
  border-radius: 5px;
  font-size: 18px; /* 增大字体 */
  font-weight: bold; /* 加粗字体 */
}

.divider {
  height: 2px;
  background-color: black; /* 黑色线条 */
  margin: 20px 0; /* 上下间距 */
}

.house-cards {
  flex: 1; /* 占据剩余空间 */
  display: flex;
  flex-wrap: wrap;
  margin: 10px;
  gap: 2%; /* 卡片间距 */
  overflow-y: auto; /* 添加垂直滚动条 */
  justify-content: space-between; /* 卡片均匀分布 */
  height: calc(100% - 80px); /* 减去搜索栏和分割线的高度 */
  box-sizing: border-box; /* 包括内边距和边框 */
  scrollbar-width: none; /* 隐藏 Firefox 滚动条 */
}

.house-cards::-webkit-scrollbar {
  display: none; /* 隐藏 Chrome 和 Safari 滚动条 */
}

.house-card {
  width: 23%; /* 四个卡片加间距刚好占满一行 */
  height: calc((100% - 4% * 2) / 3); /* 三行卡片加间距刚好填满剩余空间 */
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 10px;
  cursor: pointer;
  text-align: center;
  box-sizing: border-box; /* 包括内边距和边框 */
}

.house-card img {
  width: 100%;
  height: 60%; /* 图片高度占卡片的60% */
  border-radius: 8px;
  object-fit: cover; /* 确保图片适应卡片大小 */
}
</style>
