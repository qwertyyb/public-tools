const axios = require("axios");
const clip = require('simple-mac-clipboard')

const getResponse = (text) => axios.get(`https://dict-co.iciba.com/api/dictionary.php?w=${encodeURIComponent(text)}&type=json&key=0CD3A4C079D2D23C683BBFF96300E924`)
  .then(res => {
    const { symbols, exchange, word_name: word = '' } = res.data;
    const first = {
      id: word,
      title: word,
      subtitle: text,
      description: '',
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
            const description = mean.word_mean
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

const translatePlugin = utils => ({
  async onSearch(keyword) {
    if (!keyword) return [];
    const list = await getResponse(keyword)
    return list;
  },
  onEnter () {},
  onExit () {},
  onResultSelected(result) {
    return null;
  },
  onResultTap(result) {
    clip.writeText(clip.FORMAT_PLAIN_TEXT, result.id)
    utils.toast('已复制到粘贴板')
  }
});

module.exports = translatePlugin;
