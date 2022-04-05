const magicPlugin = utils => ({
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
    const editorPageTest = {
      title: `http://test.magic.oa.com/v4/editor/${keyword}`,
      subtitle: 'H5编辑页(测试)',
      description: '',
      icon: 'https://vfiles.gtimg.cn/vupload/20211210/13075e1639102744067.png',
      id: 'magic:editor:test',
    }
    const modPageTest = {
      id: 'mod-list',
      title: `http://test.magic.oa.com/v4/act/view/${keyword}`,
      subtitle: '模块编辑页(测试)',
      description: '',
      icon: 'https://vfiles.gtimg.cn/vupload/20211210/13075e1639102744067.png',
      id: 'magic:mod:test',
    }
    return [editorPage, modPage, editorPageTest, modPageTest];
  },
  onResultTap(result) {
    require('child_process').exec(`open ${result.title}`)
  },
  onEnter() {},
  onExit() {},
  onResultSelected() {
    console.log('abcddd')
    return 'htmlabcddd'
  },
});

module.exports = magicPlugin
