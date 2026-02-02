import axios from 'axios';

function createInstance(baseURL: string, config = {}) {
  const instance = axios.create({
    baseURL,
    ...config,
  });
  
  return instance;
}

export default createInstance;