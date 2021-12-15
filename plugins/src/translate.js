const axios = require("axios");
const createPlugin = require("./core/plugin");
const clip = require('simple-mac-clipboard')

const TRIGGERS = ['fy', 'ts', 'trans', 'translate', '翻译']

// const getResponse = (text) => axios.get(`http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=${encodeURIComponent(text)}`)
//   .then(res => {
//     const { tgt } = res.data.translateResult[0][0]
//     return [{
//       id: tgt,
//       title: tgt,
//       subtitle: '来自有道翻译',
//       icon: 'https://img.icons8.com/color/144/000000/google-translate.png'
//     }]
//   })

const getResponse = (text) => axios.get(`https://dict-co.iciba.com/api/dictionary.php?w=${encodeURIComponent(text)}&type=json&key=0CD3A4C079D2D23C683BBFF96300E924`)
  .then(res => {
    const { symbols, exchange, word_name: word = '' } = res.data;
    const first = {
      id: word,
      title: word,
      subtitle: '',
      icon: 'https://img.icons8.com/color/144/000000/google-translate.png'
    }
    console.log(text, res.data)
    const list = symbols.map(symbol => {
      const { word_symbol: pinyin, parts = [] } = symbol
      const isZh = !!pinyin
      return (parts || []).map(part => {
        if (isZh) {
          return part.means.map(mean => {
            const title = mean.word_mean
            const subtitle = ''
            const icon = 'https://img.icons8.com/color/144/000000/google-translate.png'
            return { title, subtitle, icon, id: title}
          })
        }
        const title = part.part + ' ' + part.means.join(',')
        const subtitle = ''
        const icon = 'https://img.icons8.com/color/144/000000/google-translate.png'
        return { title, subtitle, icon, id: text }
      })
    }).flat(2);
    list.unshift(first)
    return list;
  })

const plugin = createPlugin('translate', {
  title: '翻译',
  subtitle: '翻译输入内容',
  icon: 'https://img.icons8.com/color/144/000000/google-translate.png',
})

plugin.onKeywordChange(async ({ keyword }) => {
  if (!keyword) return plugin.updateList(keyword, [])
  const list = await getResponse(keyword)
  console.log('keyword', keyword, list);
  plugin.updateList(keyword, list)
})
plugin.onTap((item) => {
  clip.writeText(clip.FORMAT_PLAIN_TEXT, item.id)
  plugin.toast({ content: '已复制到粘贴板' })
})

module.exports = plugin