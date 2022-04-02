const { selectFile } = require('./build/Release/fileSelector.node')

const plugin = utils => ({
  onEnter() {},
  onExit() {},
  onSearch() {
    return [
      {
        id: 'select-plugin',
        title: '选择插件',
        subtitle: '选择插件',
        description: '',
        icon: 'https://vfiles.gtimg.cn/vupload/20211210/13075e1639102744067.png',
      }
    ]
  },
  onResultSelected(result) {
    return null;
  },
  onResultTap(result) {
    console.log('result', result);
    setTimeout(() => {
      const file = selectFile()

      console.log('selected file', file)
    })
  }
})

module.exports = plugin