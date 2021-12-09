const cv = require('./lib/ready_opencv')

const detectWithOpencv = (() => {
  let wr = null
  return (imgdata) => {
    // const data = image.toBitmap();
    // const size = image.getSize();
    
    // const imgdata = {
    //   ...size,
    //   data
    // }
    // console.log()
    if (!wr) {
      console.log(cv)
      wr = new cv.wechat_qrcode_WeChatQRCode("wechat_qrcode/detect.prototxt", "wechat_qrcode/detect.caffemodel", "wechat_qrcode/sr.prototxt", "wechat_qrcode/sr.caffemodel")
    }

    const results = wr.detectAndDecode(cv.matFromImageData(imgdata))
    if (results.size() < 1) {
      throw new Error('未识别到二维码')
    }
    let i = 0
    let arr = []
    while(i < results.size()) {
      arr.push(results.get(i++))
    }
    results.delete()
    // @ts-ignore
    console.log(arr)
    return arr
  }
})()

module.exports = detectWithOpencv

