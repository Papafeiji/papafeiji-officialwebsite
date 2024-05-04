import Sm4js from 'sm4js'

export const sm4Encryption = (str: string) => {
  const KEY = 'cf5ec33d1789c4ed'
  let sm4Config = {
    key: KEY,
    mode: 'ecb',
    cipherType: 'base64'
  }
  let sm4 = new Sm4js(sm4Config)
  return sm4.encrypt(str);
};
