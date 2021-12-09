const clip = require('simple-mac-clipboard')
const jimp = require('jimp')
const getImageSize = require('buffer-image-size')
const detectWithOpencv = require('./qrcode/index')

setTimeout(() => {
  const pngBuffer = clip.readBuffer('public.png')
  if (pngBuffer.byteLength === 0) {
    console.log('empty')
  } else {
    console.log('hasPng', getImageSize(pngBuffer))
    jimp.read(pngBuffer)
    .then(image => {
      console.log(image.bitmap)
      const { width, height, data } = image.bitmap
      const result = detectWithOpencv({ width, height, data })
      console.log(result)
    })
  }
}, 4000)

