import axios from 'axios';

export const BASE_URL = 'https://pro.papafeiji.cn/api/prod';
// export const BASE_URL = '/api';

export const getToken = () => {
  const token = JSON.parse(localStorage.getItem('token') || JSON.stringify(''));
  return token;
};

/**
 *
 * @param {string} token
 */
export const setToken = (token: string) => {
  localStorage.setItem('token', JSON.stringify(token));
};

/**
 * 清除token
 */
export const clearToken = () => {
  localStorage.removeItem('token');
};

const service = axios.create({
  baseURL: BASE_URL,
  timeout: 20000,
});

export const download = () => {
  const downloadService = axios.create({
    baseURL: BASE_URL,
    timeout: 20000,
  });

  const token = getToken();
  downloadService({
    url: '/official/exportDiaryExcel',
    responseType: 'blob',
    method: 'get',
    headers: {
      token,
    },
  })
    .then((res: any) => {
      const src = window.URL.createObjectURL(res.data);
      const fileName = decodeURIComponent(res.headers['content-disposition'].split('=')['1']);
      let link = document.createElement('a');
      link.style.display = 'none';
      link.href = src;
      link.setAttribute('download', fileName);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      window.URL.revokeObjectURL(src);
    })
    .catch((error) => {
      alert('文件下载失败');
    });
};

service.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.token = token;
  }
  return config;
});

service.interceptors.response.use(
  ({ data }) => {
    if (data.code !== '0000') {
      if (data.code == '1011') {
        clearToken();
        throw new Error(data.msg);
      }
      if (data.code == '1006') {
        clearToken();
        throw new Error(data.msg);
      }
      alert(data.msg);
      throw new Error(data.msg);
    }
    return data;
  },
  (err) => {
    if (err.code == 'ERROR_CODE') {
      alert('网络错误');
    }
    if (err.code == 'ECONNABORTED') {
      alert('请求超时，请稍后重试');
    }
    if (err.code == 'ERR_NETWORK') {
      alert('网络错误，刷新页面后重试');
    } else {
      alert(err.message);
    }
    return Promise.reject(err);
  }
);

export default service;
