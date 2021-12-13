const axios = require("axios");
const createPlugin = require("./core/plugin");
const clip = require('simple-mac-clipboard')

const TRIGGERS = ['fy', 'ts', 'trans', 'translate', '翻译']

const getResponse = (text) => axios.get(`http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=${encodeURIComponent(text)}`)
  .then(res => {
    console.log(text)
    return res.data.translateResult[0][0]
  })

const plugin = createPlugin('translate', {
  title: '翻译',
  subtitle: '翻译输入内容',
  icon: 'https://img.icons8.com/color/144/000000/google-translate.png',
})

plugin.onKeywordChange(async ({ keyword }) => {
  if (!keyword) return plugin.updateList(keyword, [])
  const response = await getResponse(keyword)
  console.log(response);
  const list = [{
    id: response.tgt,
    title: response.tgt,
    subtitle: '来自有道翻译',
    icon: 'https://img.icons8.com/color/144/000000/google-translate.png'
  }]
  plugin.updateList(keyword, list)
})
plugin.onTap((item) => {
  clip.writeText(clip.FORMAT_PLAIN_TEXT, item.id)
  plugin.toast({ content: '已复制到粘贴板' })
})

module.exports = plugin