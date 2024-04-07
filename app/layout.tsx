import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: '爬爬飞记',
  description: '爬爬飞记可以记录你生活中发生的一切，当你的完美记忆助手',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}
        <footer className="global-footer">
          <a href='https://beian.miit.gov.cn/'>Copyright © 杭州爬爬飞记科技有限公司  浙 ICP 备 2023038455 号</a>
        </footer>
      </body>
    </html>
  )
}
