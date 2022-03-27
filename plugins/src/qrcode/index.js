const clip = require('simple-mac-clipboard')
const robot = require('robotjs')
const jimp = require('jimp')
const QRCode = require('qrcode')
const detectWithOpencv = require('./detectWithOpencv')
const createPlugin = require('../core/plugin')

const readQrcodeFromClipboard = () => {
  const pngBuffer = clip.readBuffer('public.png')
  if (pngBuffer.byteLength === 0) {
    console.log('clipboard no image')
    return []
  } else {
    return jimp.read(pngBuffer)
    .then(image => {
      const { width, height, data } = image.bitmap
      const result = detectWithOpencv({ width, height, data: data })
      return result
    })
  }
}

const plugin = createPlugin((utils) => ({
  id: 'qrcode',
  title: '二维码',
  subtitle: '生成、识别二维码',
  description: '生成、识别二维码',
  mode: 'listView',
  keywords: ['二维码', 'qrcode', 'qr', '二维码识别', 'qrcode识别', 'qr识别'],
  icon: 'https://img.icons8.com/pastel-glyph/64/4a90e2/qr-code--v1.png',

  onEnter: async () => {
    console.log('onEnter')
  },

  onSearch: async (keyword) => {
    console.log('onSearch', keyword)
    if (keyword) {
      return [{
        id: 'qrcode-generator',
        title: keyword,
        subtitle: '生成二维码',
        description: '',
        icon: 'https://img.icons8.com/pastel-glyph/64/4a90e2/qr-code--v1.png'
      }]
    }
    const results = await readQrcodeFromClipboard();
    const list = results.map(result => {
      return {
        id: `clipboard_${result}`,
        title: result,
        subtitle: '剪切板中的二维码，点击复制',
        description: result,
        icon: 'https://img.icons8.com/pastel-glyph/64/4a90e2/qr-code--v1.png'
      }
    })
    list.push({
      id: 'screen',
      title: '自动识别',
      subtitle: '自动识别当前屏幕中的二维码',
      description: '自动识别当前屏幕中的二维码',
      icon: 'https://img.icons8.com/pastel-glyph/64/4a90e2/qr-code--v1.png'
    })
    return list;
  },

  onResultSelected: async (result) => {
    console.log('onResultSelected', result)
    if (result.id === 'qrcode-generator') {
      const url = await new Promise(resolve => QRCode.toDataURL(result.title, {}, (err, url) => {
        resolve(url)
      }))
      return `<div style="margin-left:100px"><img src="${url}" width="200" height="200"/></div>`
    }
    return null
  },

  onResultTap: async (result) => {
    if (result.id === 'screen') {
      utils.hideApp();
      await new Promise(resolve => setTimeout(resolve, 50))
      const bitmap = robot.screen.capture();
      const results = detectWithOpencv({ data: bitmap.image, width: bitmap.width, height: bitmap.height })
      if (!results.length) {
        utils.showApp();
        return utils.toast('未在当前屏幕检测到二维码')
      } else {
        utils.toast(`已在当前屏幕检测到${results.length}个二维码`)
      }
      const list = results.map(result => {
        return {
          id: `clipboard_${result}`,
          title: result,
          subtitle: '当前屏幕中的二维码，点击复制',
          icon: 'https://img.icons8.com/pastel-glyph/64/4a90e2/qr-code--v1.png'
        }
      })
      list.push({
        id: 'screen',
        title: '自动识别',
        subtitle: '自动识别当前屏幕中的二维码',
        icon: 'https://img.icons8.com/pastel-glyph/64/4a90e2/qr-code--v1.png'
      })
      utils.showApp()
      utils.updateResults(list)
      return;
    }
    
    clip.writeText('public.utf8-plain-text', result.title)
    utils.toast('已复制')
    setTimeout(() => {
      utils.hideApp()
    }, 500)
  },

  onExit: async (command) => {
  }
}))

module.exports = plugin

