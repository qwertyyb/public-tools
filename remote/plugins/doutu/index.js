const clipboard = require('simple-mac-clipboard')
const axios = require('axios')
const cheerio = require('cheerio')

const getImageList = async (keyword) => {
  const res = await axios.get('https://www.doutula.com/search', {
    params: {
      keyword
    },
    responseType: 'text'
  })
  const $ = cheerio.load(res.data || '')
  let list = []
  $('.img-responsive').each((i, item) => {
    list.push({
      image: $(item).attr('data-original'),
      title: $(item).siblings('p').text()
    })
  })
  return list;
}

const plugin = utils => ({
  onEnter: () => {},
  onExit: () => {},

  async onSearch(keyword) {
    if (!keyword) return []
    const list = await getImageList(keyword)
    return list.map(item => ({
      title: item.title,
      subtitle: '',
      icon: item.image || '',
      id: item.image,
      description: ''
    }))
  },
  onResultSelected(result) {
    return `
      <div>
        <div style="text-align:center">
          <img src="${result.id}" style="width:300px"/>
        </div>
        <p style="text-align:center">${result.title}</p>
      </div>
    `
  },
  onResultTap(result) {
    clipboard.writeText('public.html', Buffer.from('<img src="' + result.id + '"/>'))
    utils.toast('已复制到剪贴板,找个地方粘贴吧')
    setTimeout(() => {
      utils.hideApp()
    }, 200)
  }
})

module.exports = plugin
