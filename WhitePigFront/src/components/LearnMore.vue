<template>
  <div class="learn-more">
    <div class="content">
      <h3>项目 GitHub 地址</h3>
      <p>
        您可以在以下地址找到我的项目代码：
        <a href="https://github.com/liukuns/WhitePig" target="_blank">https://github.com/liukuns/WhitePig</a>
      </p>
      <h3>项目 Contract地址</h3>
      <p>
        PropertyMarket: 0x4A4A58F9229ab1F9cc232c6EdE427813dEC1fbAD
      </p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LearnMore'
};
</script>

<style scoped>
.learn-more {
  font-family: 'Arial', sans-serif; /* 使用简约字体 */
  padding: 30px;
  background-color: #ffffff; /* 改为纯白背景 */
  border-radius: 12px; /* 更大的圆角 */
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); /* 添加柔和阴影 */
  color: #333; /* 深灰色字体 */
}

.learn-more h2 {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 20px;
  color: #000; /* 黑色标题 */
}

.learn-more p {
  font-size: 16px;
  margin-bottom: 20px;
  line-height: 1.6;
}

.content h3 {
  font-size: 20px;
  font-weight: 600;
  margin-top: 20px;
  margin-bottom: 10px;
  color: #000; /* 黑色标题 */
}

.content p {
  font-size: 16px;
  margin-bottom: 15px;
  line-height: 1.6;
  color: #555; /* 柔和字体颜色 */
}

.content a {
  color: #007bff;
  text-decoration: none;
  font-weight: 500;
}

.content a:hover {
  text-decoration: underline;
}

.content ul {
  margin: 15px 0;
  padding-left: 20px;
  list-style-type: disc;
}

.content li {
  margin-bottom: 10px;
  font-size: 16px;
  line-height: 1.6;
  color: #555;
}
</style>
