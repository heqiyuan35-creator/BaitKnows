/**
 * 天气服务
 * 模拟器使用模拟数据，真机可启用 Weather Service Kit
 */
import { deviceInfo } from '@kit.BasicServicesKit';
import { LocationService } from './LocationService';

// 天气数据接口
export interface WeatherData {
  temperature: number;
  weatherText: string;
  humidity: number;
  windDirection: string;
  windSpeed: number;
  pressure: number;
  uvIndex: number;
  visibility: number;
  isValid: boolean;
}

// 钓鱼指数
export interface FishingIndex {
  level: string;
  color: string;
  description: string;
}

// 风向列表
const WindDirections: string[] = ['北风', '东北风', '东风', '东南风', '南风', '西南风', '西风', '西北风'];

// 缓存的天气数据
let cachedWeather: WeatherData = {
  temperature: 0,
  weatherText: '--',
  humidity: 0,
  windDirection: '--',
  windSpeed: 0,
  pressure: 0,
  uvIndex: 0,
  visibility: 0,
  isValid: false
};

// 检测是否为模拟器
function isEmulator(): boolean {
  const brand = deviceInfo.brand?.toLowerCase() || '';
  const model = deviceInfo.productModel?.toLowerCase() || '';
  return brand.includes('emulator') || model.includes('emulator') || brand === '' || model === '';
}

// 获取天气数据
export async function fetchWeather(): Promise<WeatherData> {
  const TAG = 'WeatherService';
  const location = LocationService.currentLocation;

  if (!location.isValid) {
    console.error(TAG, 'Location not available');
    return getMockWeather();
  }

  // 模拟器使用模拟数据
  if (isEmulator()) {
    console.info(TAG, 'Running on emulator, using mock weather data');
    return getMockWeather();
  }

  // ============================================================
  // 【真机天气服务】Weather Service Kit
  // 模拟器不支持此服务会崩溃，真机测试时取消下方注释
  // 使用方法：
  // 1. 取消下方 /* */ 注释
  // 2. 在文件顶部添加: import { weatherService } from '@kit.WeatherServiceKit';
  // 3. 真机运行测试
  // ============================================================
  /*
  try {
    const request: weatherService.WeatherRequest = {
      location: {
        latitude: Math.round(location.latitude * 100) / 100,  // 精确到小数点后2位
        longitude: Math.round(location.longitude * 100) / 100
      },
      limitedDatasets: [weatherService.Dataset.CURRENT]  // 只请求实况数据
    };

    const weather = await weatherService.getWeather(request);

    if (weather.current) {
      const current = weather.current;
      const temp = current.temperature ?? 0;
      const humid = current.humidity ?? 0;
      const press = current.pressure ?? 0;
      const vis = current.visibility ?? 0;

      // 获取风速和风向
      let windSpeedVal = 0;
      let windDirVal = 0;
      if (current.wind) {
        const windData = current.wind as weatherService.Wind;
        windSpeedVal = windData.speed ?? 0;
        windDirVal = windData.direction ?? 0;
      }

      // 获取紫外线指数
      let uvVal = 0;
      if (current.uvIndex) {
        const uvData = current.uvIndex as weatherService.UVIndex;
        uvVal = uvData.value ?? 0;
      }

      // 根据温度湿度推断天气描述
      let weatherText = '多云';
      if (humid > 85) weatherText = '阴';
      else if (temp > 30) weatherText = '晴热';
      else if (temp > 20 && humid < 60) weatherText = '晴';
      else if (temp < 5) weatherText = '阴冷';

      cachedWeather = {
        temperature: temp,
        weatherText: weatherText,
        humidity: humid,
        windDirection: WindDirections[Math.round(windDirVal / 45) % 8],
        windSpeed: windSpeedVal,
        pressure: press,
        uvIndex: uvVal,
        visibility: vis,
        isValid: true
      };

      console.info(TAG, `Real weather: ${cachedWeather.temperature}°C, ${cachedWeather.weatherText}`);
      return cachedWeather;
    }
  } catch (err) {
    console.error(TAG, 'Weather Service Kit failed, fallback to mock data:', err);
  }
  */
  // ============================================================

  return getMockWeather();
}

// 模拟天气数据（基于武汉当前季节）
function getMockWeather(): WeatherData {
  const month = new Date().getMonth() + 1;
  const hour = new Date().getHours();
  const day = new Date().getDate();

  let temp: number;
  let weatherText: string;
  let humidity: number;

  // 使用日期作为随机种子，同一天数据一致
  const seed = day * 7 + month;

  if (month === 12 || month === 1 || month === 2) {
    // 冬季武汉：0-10度
    temp = 2 + (seed % 8);
    if (hour >= 6 && hour <= 8) temp -= 2;
    if (hour >= 12 && hour <= 15) temp += 3;
    if (hour >= 20) temp -= 1;
    weatherText = (seed % 3 === 0) ? '阴' : '多云';
    humidity = 65 + (seed % 20);
  } else if (month >= 6 && month <= 8) {
    // 夏季武汉：28-38度
    temp = 28 + (seed % 10);
    if (hour >= 12 && hour <= 15) temp += 3;
    weatherText = (seed % 2 === 0) ? '晴' : '多云';
    humidity = 55 + (seed % 25);
  } else if (month >= 3 && month <= 5) {
    // 春季
    temp = 12 + (seed % 12);
    weatherText = '多云';
    humidity = 50 + (seed % 25);
  } else {
    // 秋季
    temp = 15 + (seed % 12);
    weatherText = (seed % 3 === 0) ? '晴' : '多云';
    humidity = 50 + (seed % 20);
  }

  const windIndex = seed % 8;

  cachedWeather = {
    temperature: temp,
    weatherText: weatherText,
    humidity: humidity,
    windDirection: WindDirections[windIndex],
    windSpeed: 3 + (seed % 12),
    pressure: 1010 + (seed % 15),
    uvIndex: (month >= 5 && month <= 9) ? 5 + (seed % 4) : 1 + (seed % 3),
    visibility: 8 + (seed % 7),
    isValid: true
  };

  return cachedWeather;
}

// 获取缓存的天气
export function getCachedWeather(): WeatherData {
  return cachedWeather;
}

// 计算钓鱼指数
export function calculateFishingIndex(weather: WeatherData): FishingIndex {
  if (!weather.isValid) {
    return { level: '未知', color: '#999999', description: '暂无天气数据' };
  }

  let score = 100;

  // 温度评分
  if (weather.temperature < 5 || weather.temperature > 35) {
    score -= 40;
  } else if (weather.temperature < 10 || weather.temperature > 30) {
    score -= 20;
  } else if (weather.temperature >= 15 && weather.temperature <= 25) {
    score += 10;
  }

  // 风速评分
  if (weather.windSpeed > 25) {
    score -= 30;
  } else if (weather.windSpeed > 15) {
    score -= 15;
  } else if (weather.windSpeed < 10) {
    score += 5;
  }

  // 气压评分
  if (weather.pressure >= 1000 && weather.pressure <= 1020) {
    score += 10;
  }

  // 天气状况评分
  const badWeather = ['雨', '雪', '雷', '暴', '霾', '雾'];
  const goodWeather = ['晴', '多云'];
  if (badWeather.some(w => weather.weatherText.includes(w))) {
    score -= 25;
  } else if (goodWeather.some(w => weather.weatherText.includes(w))) {
    score += 5;
  }

  if (score >= 80) {
    return { level: '适宜', color: '#4CAF50', description: '天气条件非常适合钓鱼' };
  } else if (score >= 60) {
    return { level: '一般', color: '#FF9800', description: '天气条件尚可，注意防护' };
  } else {
    return { level: '不宜', color: '#F44336', description: '天气条件不佳，建议改日' };
  }
}
