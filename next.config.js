/** @type {import('next').NextConfig} */
const isProd = process.env.NODE_ENV === 'production'
const nextConfig = {
  basePath: '',
  output: 'export',
  images: {
    unoptimized: true,
  },
  async rewrites() { 
    return [ 
      { source: '/api/:path*', destination: `https://pro.papafeiji.cn/api/prod/:path*` }, 
    ]
  },
}

module.exports = nextConfig
