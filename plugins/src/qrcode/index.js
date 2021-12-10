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
      wr = new cv.wechat_qrcode_WeChatQRCode("wechat_qrcode/detect.prototxt", "wechat_qrcode/detect.caffemodel", "wechat_qrcode/sr.prototxt", "wechat_qrcode/sr.caffemodel")
    }

    const results = wr.detectAndDecode(cv.matFromImageData(imgdata))
    if (results.size() < 1) {
      return []
    }
    let i = 0
    let arr = []
    while(i < results.size()) {
      arr.push(results.get(i++))
    }
    results.delete()
    return arr
  }
})()

module.exports = detectWithOpencv

