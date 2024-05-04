import { useState } from 'react'
import Image from 'next/image'
import '../../app/globals.css'
import './login.css'
import request from '../../utils/request'
import { sm4Encryption } from '../../utils/utils'
import Router from "next/router"
import { setToken } from '../../utils/request'

export default function Login() {
  const [codeTxt, setCodeTxt] = useState('获取验证码')
  const [phoneNumber, setPhoneNumber] = useState('')
  const [code, setCode] = useState('')

  let time = 0
  const sendCode = async () => {
    if (!/^1[3456789]\d{9}$/.test(phoneNumber)) {
      alert('请输入正确的手机号')
      return;
    }
    try {
      setCodeTxt('发送中')
      await request.post('/sms/sendOfficialLoginMsg', {
        phone: sm4Encryption(phoneNumber),
      })
      setCodeTxt('重新获取(60s)')
      time = 60
      var timer = setInterval(() => {
        if (time == 0) {
          clearInterval(timer);
          setCodeTxt('获取验证码')
        } else {
          setCodeTxt(`重新获取(${time - 1}s)`)
          time = time - 1
        }
      }, 1000);
    } catch (error) {
      setCodeTxt('获取验证码')
    }
  }

  const login = async () => {
    if (!/^1[3456789]\d{9}$/.test(phoneNumber)) {
      alert('请输入正确的手机号')
      return;
    }
    if (!code) {
      alert('请输入验证码')
      return;
    }
    try {
      const { data } = await request.post('/auth/officialLogin', {
        phone: sm4Encryption(phoneNumber),
        code,
      })
      setToken(data)
      Router.push('/')
    } catch (error) {
    }
  }

  return (
    <>
      <main className="login-page">
        <div className='left'>
          <Image
            className='login-img'
            src="/login.png"
            alt="login"
            width={1100}
            height={1230}
          />
        </div>
        <div className='right'>
          <div className="main">
            <p className='title'>登录</p>
            <div className='item'>
              <div className="label">手机号</div>
              <input value={phoneNumber} onChange={(e) => { setPhoneNumber(e.target.value) }} className='input' placeholder='请输入手机号' />
            </div>
            <div className='item'>
              <div className="label">短信验证码</div>
              <div className='input'>
                <input value={code} onChange={(e) => { setCode(e.target.value) }} placeholder='请输入验证码' />
                <button disabled={codeTxt != '获取验证码'} onClick={sendCode}>{codeTxt}</button>
              </div>
            </div>
            <div onClick={login} className='btn'>登录</div>
          </div>
        </div>
      </main>
      <footer className="global-footer">
        <a href='https://beian.miit.gov.cn/'>Copyright © 杭州爬爬飞记科技有限公司  浙 ICP 备 2024085343号-2</a>
      </footer>
    </>
  )
}