
const base = require('./plugin')

base.onKeywordChange((keyword) => {
  const list = [
    {
      icon: 'https://via.placeholder.com/50',
      title: keyword,
      subtitle: 'subtitle-' + keyword,
      id: 'abc'
    }
  ]
  base.updateList(keyword, list)
})
