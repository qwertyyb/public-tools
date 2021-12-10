const mdnPlugin = require('./mdn')
const qrcodePlugin = require('./qrcode.js')
const magicPlugin = require('./magic')

module.exports = () => ([mdnPlugin, qrcodePlugin, magicPlugin])