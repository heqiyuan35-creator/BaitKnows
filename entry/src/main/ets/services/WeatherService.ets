/**
 * 天气服务 - 使用和风天气API
 */
import { http } from '@kit.NetworkKit';
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

// 和风天气API响应接口
interface QWeatherNow {
  temp: string;
  text: string;
  humidity: string;
  windDir: string;
  windSpeed: string;
  pressure: string;
  vis: string;
}

interface QWeatherResponse {
  code: string;
  now: QWeatherNow;
}

// ============================================================
// 【配置区】和风天气API
// ============================================================
const QWEATHER_HOST = 'mv2pg7eyad.re.qweatherapi.com';
const QWEATHER_KEY = 'YOUR_QWEATHER_API_KEY';  // 请替换为你的和风天气API Key
// ============================================================

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

// 等待定位完成（最多等待5秒）
async function waitForLocation(): Promise<boolean> {
  const TAG = 'WeatherService';
  let location = LocationService.currentLocation;
  
  // 如果已经有有效位置，直接返回
  if (location.isValid && location.latitude !== 30.5844) {
    console.info(TAG, `位置已就绪: ${location.latitude}, ${location.longitude}`);
    return true;
  }
  
  // 等待定位完成
  console.info(TAG, '等待定位服务...');
  for (let i = 0; i < 10; i++) {
    await new Promise<void>((resolve) => setTimeout(resolve, 500));
    location = LocationService.currentLocation;
    // 检查是否获取到真实位置（非默认武汉坐标）
    if (location.isValid && (location.latitude !== 30.5844 || location.longitude !== 114.2986)) {
      console.info(TAG, `定位成功: ${location.latitude}, ${location.longitude}`);
      return true;
    }
  }
  
  console.warn(TAG, '定位超时，使用当前位置');
  return location.isValid;
}

// 获取天气数据
export async function fetchWeather(): Promise<WeatherData> {
  const TAG = 'WeatherService';
  
  // 先等待定位完成
  const hasLocation = await waitForLocation();
  const location = LocationService.currentLocation;

  console.info(TAG, `fetchWeather: hasLocation=${hasLocation}, lat=${location.latitude}, lng=${location.longitude}`);

  if (!hasLocation || !location.isValid) {
    console.error(TAG, '无法获取位置，使用模拟天气');
    return getMockWeather();
  }

  if (QWEATHER_HOST) {
    try {
      const result = await fetchQWeather(location.latitude, location.longitude);
      console.info(TAG, `和风天气返回: isValid=${result.isValid}, 温度=${result.temperature}°C, 天气=${result.weatherText}`);
      if (result.isValid) {
        cachedWeather = result;
        console.info(TAG, `使用真实天气数据`);
        return result;
      }
    } catch (err) {
      console.error(TAG, `和风天气请求失败: ${err}`);
    }
  }

  console.info(TAG, '使用模拟天气');
  return getMockWeather();
}

// 和风天气API
async function fetchQWeather(lat: number, lng: number): Promise<WeatherData> {
  const TAG = 'QWeather';
  // 使用更高精度的坐标（保留6位小数以获得最精确的天气数据）
  const url = `https://${QWEATHER_HOST}/v7/weather/now?location=${lng.toFixed(6)},${lat.toFixed(6)}&key=${QWEATHER_KEY}`;

  console.info(TAG, `========== 和风天气API请求 ==========`);
  console.info(TAG, `用户坐标: 纬度=${lat.toFixed(6)}, 经度=${lng.toFixed(6)}`);
  console.info(TAG, `请求URL: ${url}`);
  const httpRequest = http.createHttp();

  const emptyResult: WeatherData = {
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

  try {
    const response = await httpRequest.request(url, {
      method: http.RequestMethod.GET,
      header: { 'Content-Type': 'application/json' },
      connectTimeout: 15000,
      readTimeout: 15000
    });

    console.info(TAG, `HTTP响应状态码: ${response.responseCode}`);
    if (response.responseCode === 200) {
      const resultStr = response.result as string;
      console.info(TAG, `API响应数据: ${resultStr}`);
      
      const data: QWeatherResponse = JSON.parse(resultStr);

      if (data.code === '200' && data.now) {
        const now = data.now;
        console.info(TAG, `========== 天气数据解析成功 ==========`);
        console.info(TAG, `温度: ${now.temp}°C`);
        console.info(TAG, `天气: ${now.text}`);
        console.info(TAG, `湿度: ${now.humidity}%`);
        console.info(TAG, `风向: ${now.windDir}`);
        console.info(TAG, `风速: ${now.windSpeed}km/h`);
        console.info(TAG, `气压: ${now.pressure}hPa`);
        console.info(TAG, `能见度: ${now.vis}km`);
        console.info(TAG, `==========================================`);
        
        const result: WeatherData = {
          temperature: parseInt(now.temp) || 0,
          weatherText: now.text || '未知',
          humidity: parseInt(now.humidity) || 0,
          windDirection: now.windDir || '微风',
          windSpeed: parseInt(now.windSpeed) || 0,
          pressure: parseInt(now.pressure) || 1013,
          uvIndex: 0,
          visibility: parseInt(now.vis) || 10,
          isValid: true
        };
        
        httpRequest.destroy();
        return result;
      } else {
        console.error(TAG, `API返回错误: code=${data.code}`);
      }
    } else {
      console.error(TAG, `HTTP错误: ${response.responseCode}`);
    }
  } catch (err) {
    console.error(TAG, `请求异常: ${err}`);
  }

  httpRequest.destroy();
  return emptyResult;
}

// 模拟天气数据
function getMockWeather(): WeatherData {
  const month = new Date().getMonth() + 1;
  const hour = new Date().getHours();
  const day = new Date().getDate();
  const seed = day * 7 + month;

  let temp: number;
  let weatherText: string;
  let humidity: number;

  if (month === 12 || month === 1 || month === 2) {
    temp = 2 + (seed % 8);
    if (hour >= 12 && hour <= 15) temp += 3;
    weatherText = (seed % 3 === 0) ? '阴' : '多云';
    humidity = 65 + (seed % 20);
  } else if (month >= 6 && month <= 8) {
    temp = 28 + (seed % 10);
    if (hour >= 12 && hour <= 15) temp += 3;
    weatherText = (seed % 2 === 0) ? '晴' : '多云';
    humidity = 55 + (seed % 25);
  } else if (month >= 3 && month <= 5) {
    temp = 12 + (seed % 12);
    weatherText = '多云';
    humidity = 50 + (seed % 25);
  } else {
    temp = 15 + (seed % 12);
    weatherText = (seed % 3 === 0) ? '晴' : '多云';
    humidity = 50 + (seed % 20);
  }

  const windDirs: string[] = ['北风', '东北风', '东风', '东南风', '南风', '西南风', '西风', '西北风'];

  cachedWeather = {
    temperature: temp,
    weatherText: weatherText,
    humidity: humidity,
    windDirection: windDirs[seed % 8],
    windSpeed: 5 + (seed % 15),
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

// 强制刷新天气（先刷新位置，再获取天气）
export async function refreshWeather(): Promise<WeatherData> {
  const TAG = 'WeatherService';
  console.info(TAG, '强制刷新天气数据...');
  
  // 先刷新位置
  try {
    await LocationService.refreshLocation();
    console.info(TAG, '位置已刷新');
  } catch (err) {
    console.warn(TAG, `刷新位置失败: ${err}`);
  }
  
  // 重新获取天气
  return fetchWeather();
}

// 计算钓鱼指数
export function calculateFishingIndex(weather: WeatherData): FishingIndex {
  if (!weather.isValid) {
    return { level: '未知', color: '#999999', description: '暂无天气数据' };
  }

  let score = 100;
  const TAG = 'FishingIndex';

  // 温度评分（最佳15-25°C）
  if (weather.temperature < 5 || weather.temperature > 35) {
    score -= 40;
  } else if (weather.temperature < 10 || weather.temperature > 30) {
    score -= 20;
  } else if (weather.temperature < 15 || weather.temperature > 25) {
    score -= 5;  // 10-15°C 或 25-30°C 轻微扣分
  } else {
    score += 10;  // 15-25°C 最佳
  }

  // 风速评分（最佳 < 8km/h）
  if (weather.windSpeed > 25) {
    score -= 35;
  } else if (weather.windSpeed > 18) {
    score -= 25;
  } else if (weather.windSpeed > 12) {
    score -= 15;  // 12-18km/h 中等风
  } else if (weather.windSpeed > 8) {
    score -= 5;   // 8-12km/h 轻风
  } else {
    score += 5;   // < 8km/h 微风最佳
  }

  // 气压评分（最佳 1005-1025 hPa）
  if (weather.pressure >= 1005 && weather.pressure <= 1025) {
    score += 10;
  } else if (weather.pressure < 990 || weather.pressure > 1035) {
    score -= 15;  // 极端气压
  }

  // 天气状况评分
  const badWeather: string[] = ['雨', '雪', '雷', '暴', '霾', '雾'];
  const normalWeather: string[] = ['阴'];  // 阴天轻微扣分
  const goodWeather: string[] = ['晴', '多云'];

  if (badWeather.some((w: string) => weather.weatherText.includes(w))) {
    score -= 25;
  } else if (normalWeather.some((w: string) => weather.weatherText.includes(w))) {
    score -= 10;  // 阴天不太理想
  } else if (goodWeather.some((w: string) => weather.weatherText.includes(w))) {
    score += 5;
  }

  // 确保分数在合理范围
  score = Math.max(0, Math.min(100, score));

  console.info(TAG, `Score=${score}, temp=${weather.temperature}, wind=${weather.windSpeed}, pressure=${weather.pressure}, weather=${weather.weatherText}`);

  if (score >= 80) {
    return { level: '适宜', color: '#4CAF50', description: '天气条件非常适合钓鱼' };
  } else if (score >= 60) {
    return { level: '一般', color: '#FF9800', description: '天气条件尚可，注意防护' };
  } else {
    return { level: '不宜', color: '#F44336', description: '天气条件不佳，建议改日' };
  }
}
