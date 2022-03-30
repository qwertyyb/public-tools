const createPlugin = require("./core/plugin");

const magicPlugin = createPlugin(utils => ({
  id: 'magic',
  title: '魔方平台',
  subtitle: '快速打开魔方平台对应页面',
  description: '',
  mode: 'listView',
  keywords: ['magic', '魔方平台页面打开', '魔方平台打开'],
  icon: 'https://vfiles.gtimg.cn/vupload/20211210/13075e1639102744067.png',
  onSearch(keyword) {
    if (!keyword) return [];
    const editorPage = {
      title: `http://magic.oa.com/v4/editor/${keyword}`,
      subtitle: 'H5编辑页(正式)',
      description: '',
      icon: 'https://vfiles.gtimg.cn/vupload/20211210/13075e1639102744067.png',
      id: 'magic:editor:prod',
    }
    const modPage = {
      id: 'mod-list',
      title: `http://magic.oa.com/v4/act/view/${keyword}`,
      subtitle: '模块编辑页(正式)',
      description: '',
      icon: 'https://vfiles.gtimg.cn/vupload/20211210/13075e1639102744067.png',
      id: 'magic:mod:prod',
    }
    return [editorPage, modPage];
  },
  onResultTap(result) {
    require('child_process').exec(`open ${result.title}`)
  },
  onEnter() {},
  onExit() {},
  onResultSelected() {},
}));

module.export = magicPlugin
