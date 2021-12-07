
const axios = require('axios')
const base = require('./base')

const queryResult = async (keyword = '') => {
  const params = new URLSearchParams({
    q: keyword,
    sort: 'best',
  })
  const url = 'https://developer.mozilla.org/api/v1/search/zh-CN?' + params.toString()
  const response = await axios.get(url)
  const json = response.data

  return json.documents.map(document => {
    const { title = [], body = [] } = document.highlight || {}
    const titles = title.map(t => `<h2>${t}</h2>`).join('<br />')
    const bodys = body.map(b => `<div>${b}</div>`).join('\n')
    return {
      title: document.title,
      subtitle: document.summary,
      icon: 'https://vfiles.gtimg.cn/vupload/20211129/2da75c1638159214694.png',
      url: 'https://developer.mozilla.org' + document.mdn_url,
      detail: titles + bodys
    }
  })
}

let timeout = null;
base.onKeywordChange((keyword) => {
  timeout && clearTimeout(timeout)
  timeout = setTimeout(async () => {
    const list = await queryResult(keyword)
    console.log(list);
    base.updateList(keyword, list)
  }, 20)
})

