const mdnPlugin = require('./mdn')
const qrcodePlugin = require('./qrcode/index.js')
const magicPlugin = require('./magic')
const translatePlugin = require('./translate')

module.exports = () => ([mdnPlugin, qrcodePlugin, magicPlugin, translatePlugin])

console.log('remote plugin is running')
