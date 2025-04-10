<template>
  <div class="rental-market">
    <div v-if="!showDetails">
      <div class="search-bar">
        <div id="location-filter" class="filter-item">
          <label for="location">
            <i class="fas fa-map-marker-alt"></i> 位置:
          </label>
          <input
            type="text"
            id="location"
            v-model="filters.location"
            placeholder="请输入位置"
          />
        </div>

        <div class="vertical-line"></div>

        <div id="price-filter" class="filter-item">
          <label for="price">
            <i class="fas fa-yen-sign"></i> 价格(RMB):
          </label>
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

        <div class="vertical-line"></div>

        <div id="type-filter" class="filter-item">
          <label for="type">
            <i class="fas fa-home"></i> 房屋型号:
          </label>
          <input
            type="text"
            id="type"
            v-model="filters.type"
            placeholder="请输入房屋型号"
          />
        </div>
      </div>

      <div class="divider"></div>

      <div class="house-cards">
        <div 
          v-for="house in filteredHouses" 
          :key="house.id" 
          class="house-card" 
          @click="viewDetails(house)"
        >
          <img :src="house.image" alt="房屋图片" />
          <div class="card-content">
            <h3>{{ house.location }}</h3>
            <p>{{ house.description }}</p>
            <p>型号: {{ house.type }}</p>
            <p>租金: {{ house.rent }} RMB/月</p>
          </div>
        </div>
      </div>
    </div>

    <HouseDetail
      v-else 
      :house="selectedHouse" 
      @go-back="showDetails = false"
      :userInformationContract="userInformationContract"
      :rentRequestContract="rentRequestContract"
      :rentDAOContract="rentDAOContract"
      :propertyManagementContract="propertyManagementContract"
      :propertyMarketContract="propertyMarketContract"
      :usdtContract="usdtContract"
    />
  </div>
</template>

<script>
import HouseDetail from './HouseDetail.vue';

export default {
  name: 'RentalMarket',
  props: {
    propertyManagementContract: {
      type: Object,
      required: true
    },
    propertyMarketContract: {
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
    usdtContract: {
      type: Object,
      required: true
    }
  },
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
      houses: [],
      showDetails: false, // 控制是否显示房屋详情
      selectedHouse: null // 存储选中的房屋信息
    };
  },
  computed: {
    filteredHouses() {
      if (!this.filters.location && this.filters.price === this.priceRange.max && !this.filters.type) {
        // 如果没有任何筛选条件，显示所有房源
        return this.houses;
      }
      return this.houses.filter(house => {
        const matchesLocation = this.filters.location
          ? house.location.includes(this.filters.location) // 字符串匹配位置
          : true;
        const matchesPrice = house.rent <= this.filters.price; // 价格过滤
        const matchesType = this.filters.type
          ? house.type.includes(this.filters.type) // 字符串匹配房屋型号
          : true;
        return matchesLocation && matchesPrice && matchesType;
      });
    }
  },
  async created() {
    try {
      const propertyCount = await this.propertyManagementContract.propertyCount();
      const housesData = [];

      for (let i = 1; i <= propertyCount; i++) {
        const property = await this.propertyManagementContract.getProperty(i);
        if (property.isAvailable && !property.isWithdraw) {
          housesData.push({
            id: property.propertyId,
            image: property.photos,
            location: property.location,
            description: property.description,
            type: property.propertyType,
            rent: Number(property.monthlyRent) / 10 ** 18, // 去掉 18 位精度
            owner: property.owner
          });
        }
      }

      this.houses = housesData;
    } catch (error) {
      console.error('获取房屋信息失败:', error);
      alert('无法加载房屋信息，请稍后重试');
    }
  },
  methods: {
    viewDetails(house) {
      this.selectedHouse = house; // 设置选中的房屋信息
      this.showDetails = true; // 切换到房屋详情视图
    }
  }
};
</script>

<style scoped>
.rental-market {
  background-color: #ffffff;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.search-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: #ffffff;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.filter-item {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  font-size: 14px;
}

.filter-item label {
  font-weight: bold;
  margin-bottom: 5px;
}

.filter-item select,
.filter-item input {
  width: 100%;
  padding: 5px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.house-cards {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  margin-top: 20px;
}

.house-card {
  width: 30%;
  background-color: #ffffff;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.house-card:hover {
  transform: translateY(-5px);
}

.house-card img {
  width: 100%;
  height: 150px;
  object-fit: cover;
}

.card-content {
  padding: 10px;
  text-align: left;
}

.card-content h3 {
  font-size: 18px;
  margin-bottom: 5px;
}

.card-content p {
  font-size: 14px;
  color: #555;
  margin: 5px 0;
}
</style>
