import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: '爬爬记忆助手',
  description: '爬爬记忆助手可以记录你生活中发生的一切，当你的完美记忆助手',
  openGraph: {
    title: '爬爬记忆助手',
    description: '爬爬记忆助手可以记录你生活中发生的一切，当你的完美记忆助手',
    url: 'https://www.papafeiji.cn',
    siteName: '爬爬记忆助手',
    images: [
      {
        url: 'https://www.papafeiji.cn/papafeiji.png',
        width: 800,
        height: 600,
      },
    ],
    locale: 'zh_CN',
    type: 'website',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="zh-CN">
      <body className={inter.className}>{children}
        <footer className="global-footer">
          <a href='https://beian.miit.gov.cn/'>Copyright © 杭州陈乐乐科技有限公司  浙 ICP 备 2024085343号-2</a>
        </footer>
      </body>
    </html>
  )
}
