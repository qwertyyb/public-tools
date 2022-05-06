const path = require('path')
const mdfind = require('mdfind')
const fs = require('fs')

const findFiles = (keyword) => {
  return new Promise(resolve => {
    const res = mdfind({
      names: [keyword],
      attributes: ['kMDItemFSName', 'kMDItemContentType'],
      limit: 100,
      directories: [process.env.HOME]
    })
    let results = []
    res.output.on('data', item => {
      const { kMDItemPath: path, kMDItemFSName: name, kMDItemContentType: type } = item
      const isDirectory = type === 'public.folder'
      results.push({
        path, name, isDirectory, type
      })
    })
    res.output.on('end', () => {
      results.sort((prev, next) => prev.path.length - next.path.length)
      resolve(results)
      res.terminate()
    })
  })
}

const plugin = utils => ({
  onEnter() {},
  onExit() {},
  
  onSearch(keyword) {
    if (!keyword) return [];
    return findFiles(keyword).then(results => {
      return results.map(item => {
        const { path, name, isDirectory } = item
        return {
          title: name,
          subtitle: path || '',
          icon: isDirectory ? 'https://img.icons8.com/emoji/96/000000/open-file-folder-emoji.png' : 'https://img.icons8.com/color/96/000000/file.png',
          description: '',
          id: path,
        }
      })
    })
  },
  onResultSelected() {},
  onResultTap(result) {
    // @todo 打开当前文件
    const dirPath = path.dirname(result.subtitle)
    require('child_process').exec('open ' + dirPath)
  },
})

module.exports = plugin
