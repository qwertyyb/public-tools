const math = require('mathjs')
const clibpoard = require('simple-mac-clipboard')

const calc = (str) => {
  try {
    return math.evaluate(str)
  } catch(err) {
    return NaN
  }
}

const plugin = utils => ({
  onEnter: () => {},

  onSearch: async (keyword) => {
    const val = calc(keyword)
    if (isNaN(val)) return []
    return [{
      title: '= ' + val,
      subtitle: keyword,
      icon: 'https://img.icons8.com/color/96/000000/calculator--v1.png',
      description: '',
      id: val + '',
    }]
  },

  onResultSelected: async (result) => {
    return null
  },

  onResultTap: async (result) => {
    clibpoard.writeText(clibpoard.FORMAT_PLAIN_TEXT, result.id)
    utils.toast('已复制到剪贴板')
    setTimeout(() => {
      utils.hideApp()
    }, 200)
  },

  onExit: () => {}
})

module.exports = plugin
