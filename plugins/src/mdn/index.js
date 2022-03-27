
const axios = require('axios')
const createPlugin = require('../core/plugin')

const plugin = createPlugin(utils => ({
  id: 'mdn',
  title: '搜索MDN文档',
  subtitle: '搜索MDN上的文档',
  description: '搜索MDN上的文档',
  mode: 'listView',
  keywords: ['mdn', 'docs', '文档'],
  icon: 'https://vfiles.gtimg.cn/vupload/20211129/2da75c1638159214694.png',

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
}))

// const queryResult = async (keyword = '') => {
//   const params = new URLSearchParams({
//     q: keyword,
//     sort: 'best',
//   })
//   const url = 'https://developer.mozilla.org/api/v1/search/zh-CN?topic=js&' + params.toString()
//   const response = await axios.get(url)
//   const json = response.data

//   return json.documents.map(document => {
//     const { title = [], body = [] } = document.highlight || {}
//     const titles = title.map(t => `<h2>${t}</h2>`).join('<br />')
//     const bodys = body.map(b => `<div>${b}</div>`).join('\n')
//     return {
//       title: document.title,
//       subtitle: document.summary,
//       icon: 'https://vfiles.gtimg.cn/vupload/20211129/2da75c1638159214694.png',
//       url: 'https://developer.mozilla.org' + document.mdn_url,
//       // detail: titles + bodys,
//       id: document.mdn_url
//     }
//   })
// }

// let timeout = null;
// let latestList = []
// plugin.onKeywordChange(({ keyword }) => {
//   if (!keyword) return plugin.updateList(keyword, [])
//   timeout && clearTimeout(timeout)
//   timeout = setTimeout(async () => {
//     const list = await queryResult(keyword)
//     latestList = list
//     plugin.updateList(keyword, list)
//   }, 200)
// })
// plugin.onTap(item => {
//   require('child_process').exec(`open https://developer.mozilla.org${item.id}`)
// })
// plugin.onSelect(item => {
//   const target = latestList.find(i => i.id === item.id.replace('mdn-', ''))
//   if (!target) return plugin.updatePreview({ html: '' });
//   plugin.updatePreview({ html: `<h1>${target.title}</h1><div>${target.subtitle } </div>` })
// });

module.exports = plugin
