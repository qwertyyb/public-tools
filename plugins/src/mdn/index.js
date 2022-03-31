
const axios = require('axios')

const plugin = utils => ({
  onEnter: () => {},

  onSearch: async (keyword) => {
    if (!keyword) return [];
    const params = new URLSearchParams({
      q: keyword,
      sort: 'best',
    })
    const url = 'https://developer.mozilla.org/api/v1/search/zh-CN?topic=js&' + params.toString()
    const response = await axios.get(url)
    const json = response.data
  
    return json.documents.map(document => {
      const { title = [], body = [] } = document.highlight || {}
      return {
        title: document.title,
        subtitle: document.summary,
        icon: 'https://vfiles.gtimg.cn/vupload/20211129/2da75c1638159214694.png',
        url: 'https://developer.mozilla.org' + document.mdn_url,
        description: '',
        id: document.mdn_url
      }
    })
  },

  onResultSelected: async (result) => {
    return null
  },

  onResultTap: async (result) => {
    require('child_process').exec(`open https://developer.mozilla.org${result.id}`)
  },

  onExit: () => {}
})

module.exports = plugin
