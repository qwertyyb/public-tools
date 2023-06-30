const { exec } = require('child_process')

const createPlugin = (utils) => ({
  onEnter() {},
  onExit() {},

  onSearch(keyword) {
    if (!keyword) {
      return [
        {
          title: '请输入活动id',
          subtitle: '',
          description: '',
          icon: 'https://via.placeholder.com/50',
          id: 'placeholder'
        }
      ]
    }
    const editorPage = {
      title: `http://magic.woa.com/v5/editor/${keyword}`,
      subtitle: 'H5编辑页(正式)',
      description: '',
      icon: 'https://via.placeholder.com/50',
      id: 'magic:editor:prod',
    }
    const modPage = {
      title: `http://magic.woa.com/v5/act/view/${keyword}`,
      subtitle: '模块编辑页(正式)',
      description: '',
      icon: 'https://via.placeholder.com/50',
      id: 'magic:mod:prod',
    }
    return [editorPage, modPage]
  },
  onResultSelected() { return null },
  onResultTap(result) {
    exec(`open ${result.title}`)
  }
})

module.exports = createPlugin