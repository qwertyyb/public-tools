const mdnPlugin = require('./mdn')
const qrcodePlugin = require('./qrcode/index.js')
// const magicPlugin = require('./magic')
const translatePlugin = require('./translate')
const storePlugin = require('./store')

module.exports = () => ([qrcodePlugin, mdnPlugin, storePlugin, translatePlugin])

console.log('remote plugin is running')
