const { create, all } = require('mathjs')
const clibpoard = require('simple-mac-clipboard')

const config = {
    epsilon: 1e-12,
    matrix: 'Matrix',
    number: 'BigNumber', // 可选值：number BigNumber
    precision: 64,
    predictable: false,
    randomSeed: null
}
const math = create(all, config)

const calc = (str) => {
  try {
    return math.format(math.evaluate(str))
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
