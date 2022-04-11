const axios = require('axios')

const getCandidates = async (keyword) => {
  const response = await axios.get('https://suggestqueries.google.com/complete/search?client=youtube&callback=callback', {
    params: {
      q: keyword,
    }
  })
  const parseResponse = new Function('', `const callback = data => data;return ${response.data}`)
  const data = parseResponse()
  return data?.[1]?.map(item => item[0])
};


const plugin = utils => ({
  onEnter() {},
  onExit() {},
  async onSearch(keyword) {
    if (!keyword) {
      return [
        {
          id: 'google',
          title: '谷歌搜索',
          subtitle: '打开谷歌搜索',
          description: 'https://google.com/ncr',
          icon: 'https://img.icons8.com/color/96/000000/google-logo.png',
        },
        {
          id: 'baidu',
          title: '百度搜索',
          subtitle: '打开百度搜索',
          description: 'https://baidu.com/',
          icon: 'https://img.icons8.com/color/96/000000/baidu.png',
        },
        {
          id: 'bing',
          title: '必应搜索',
          subtitle: '打开必应搜索',
          description: 'https://bing.com/',
          icon: 'https://img.icons8.com/color/96/000000/bing.png',
        }
      ]
    } else {
      const candidates = await getCandidates(keyword)
      return [keyword, ...candidates].map(candidate => {
        return {
          id: `candidate-${candidate}`,
          title: `${candidate}`,
          subtitle: `谷歌搜索 ${candidate}`,
          description: `https://google.com/search?q=${encodeURIComponent(candidate)}`,
          icon: 'https://img.icons8.com/color/96/000000/google-logo.png',
        }
      })
    }
  },
  onResultSelected(result) {
    return null
  },
  onResultTap(result) {
    require('child_process').exec(`open ${result.description}`)
    return null
  }
})

module.exports = plugin