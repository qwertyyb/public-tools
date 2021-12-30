const mdnPlugin = require('./mdn')
const qrcodePlugin = require('./qrcode/index.js')
const magicPlugin = require('./magic')
const translatePlugin = require('./translate')
const pluginStorePlugin = require('./store')

module.exports = () => ([mdnPlugin, qrcodePlugin, magicPlugin, translatePlugin, pluginStorePlugin])

console.log('remote plugin is running')
