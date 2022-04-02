const path = require('path')
const fs = require('fs')
const chokidar = require('chokidar');
const registerPlugin = require('../core/plugin')

const selectPluginFile = async () => {
  const { default: cocoaDialog } = await import('cocoa-dialog')
  const filePath = await cocoaDialog('fileselect', {
    allowedFiles: 'plugin.json',
    selectMultiple: false,
    createDirectories: true,
    selectDirectories: false,
  });
  return filePath
}

const getPluginInfo = (configPath) => {
  const config = require(configPath)
  const { name, title, subtitle, description, icon } = config
  return {
    name,
    title,
    subtitle,
    description,
    icon,
  }
}

const devPlugins = new Map()

const removeDevPlugin = (name) => {
  const values = devPlugins.get(name)
  if (!values) return;
  const { unregister } = values;
  unregister();
  devPlugins.delete(name);
}

const addDevPlugin = (configPath, utils) => {
  const unregister = registerPlugin(configPath)
  if (unregister.msg) {
    utils.showApp()
    utils.toast(unregister.msg)
  } else {
    const { name, ...info } = getPluginInfo(configPath)
    const value = devPlugins.get(name) || {}
    if (!value.fileWatcher) {
      const watcher = chokidar.watch(path.dirname(configPath), {
        ignoreInitial: true, 
        usePolling: true
      });
      watcher.on('all', (event, path) => {
        console.log('file changed, reloading plugin: ', event, path);
        // removeDevPlugin(name);
        unregister();
        addDevPlugin(configPath, utils);
      });
      utils.showApp();
      value.fileWatcher = watcher;
    }
    devPlugins.set(name, {
      ...value,
      unregister,
      config: {
        id: name, ...info
      },
      path: configPath
    })
    utils.updateResults([
      {
        id: name,
        ...info,
        subtitle: configPath,
      }
    ])
  }
}

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
      },
      ...Array.from(devPlugins.values()).map(({ config, path: filePath }) => ({
        ...config,
        subtitle: filePath
      })),
    ]
  },
  onResultSelected(result) {
    return `<h1>${result.title}</h1>`
  },
  onResultTap(result) {
    if (result.id === 'select-plugin') {
      selectPluginFile().then(filePath => {
        addDevPlugin(filePath, utils)
      })
    }
  }
})

module.exports = plugin