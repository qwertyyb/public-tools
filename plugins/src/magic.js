const createPlugin = require("./core/plugin");

const magicPlugin = createPlugin('magic', {
  icon: 'https://vfiles.gtimg.cn/vupload/20211210/13075e1639102744067.png',
  title: '魔方平台',
  subtitle: '打开魔方页面'
})

magicPlugin.onKeywordChange(({ keyword }) => {
  const editorPage = {
    title: `http://magic.oa.com/v4/editor/${keyword}`,
    subtitle: 'H5编辑页(正式)',
    icon: 'https://vfiles.gtimg.cn/vupload/20211210/13075e1639102744067.png',
    id: 'magic:editor:prod',
  }
  const modPage = {
    title: `http://magic.oa.com/v4/act/view/${keyword}`,
    subtitle: '模块编辑页(正式)',
    icon: 'https://vfiles.gtimg.cn/vupload/20211210/13075e1639102744067.png',
    id: 'magic:mod:prod',
  }
  magicPlugin.updateList(keyword, [editorPage, modPage])
})

magicPlugin.onTap(item => {
  require('child_process').exec(`open ${item.title}`)
})


module.export = magicPlugin