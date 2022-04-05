const path = require('path')
const fs = require('fs')
const chokidar = require('chokidar');
const { openFile } = require("macos-open-file-dialog")
const registerPlugin = require('../../core/plugin');

const selectPluginFile = async() => {
  try {
    const filePath = await openFile("Select a file", ['public.json'])
    return filePath
  } catch(err) {
    console.error(err)
    return ''
  }
}

const devPlugins = new Map()

const save = () => {
  const configPathList = Array.from(devPlugins.values()).map(({ path }) => path)
  fs.writeFileSync(path.join(__dirname, './dev-plugins.json'), JSON.stringify(configPathList))
}

let registered = false

const registerSavedPlugin = (utils) => {
  let configPathList = []
  try {
  configPathList = JSON.parse(fs.readFileSync(path.join(__dirname, './dev-plugins.json'), 'utf-8'))
  } catch(err) {}
  configPathList.forEach(configPath => {
    addDevPlugin(configPath, utils)
  })
}

const removeDevPlugin = (name) => {
  if (devPlugins.has(name)) {
    const { unregister, fileWatcher } = devPlugins.get(name)
    unregister()
    fileWatcher.close()
    devPlugins.delete(name)
    save();
  }
}

const addDevPlugin = (configPath, utils) => {
  const unregister = registerPlugin(configPath)
  if (unregister.msg) {
    utils.showApp()
    utils.toast(unregister.msg)
  } else {
    delete require.cache[configPath];
    const { name, ...info } = require(configPath)
    const value = devPlugins.get(name) || {}
    if (!value.fileWatcher) {
      const watcher = chokidar.watch(path.dirname(configPath), {
        ignoreInitial: true, 
        usePolling: true
      });
      watcher.on('all', (event, filePath) => {
        console.log('file changed, reloading plugin: ', event, filePath);
        unregister();
        // 删除缓存
        delete require.cache[require.resolve(path.dirname(configPath))];
        addDevPlugin(configPath, utils);
      });
      utils.showApp();
      value.fileWatcher = watcher;
    }
    devPlugins.set(name, {
      ...value,
      unregister,
      config: {
        name, ...info
      },
      path: configPath
    })
    save();
    utils.updateResults(getSearchResultList())
  }
}

const getSearchResultList = () => {
  return [
    {
      id: 'select-plugin',
      title: '选择插件',
      subtitle: '选择插件',
      description: '',
      icon: 'https://img.icons8.com/color/96/000000/json-download.png',
    },
    ...Array.from(devPlugins.values()).map(({ config, path: filePath }) => ({
      ...config,
      id: config.name,
      subtitle: filePath
    })),
  ]
}

const plugin = utils => ({
  onEnter() {
    if (registered) return;
    registerSavedPlugin(utils);
    registered = true;
  },
  onExit() {},
  onSearch() {
    return getSearchResultList()
  },
  onResultSelected(result) {
    if (result.id === 'select-plugin') return null;
    const selectedPlugin = devPlugins.get(result.id)
    if (!selectedPlugin) return null;
    return `
      <flutter-container>
        <column crossaxisalignment="start">
          <padding top="12" bottom="12">
            <row>
              <text fontWeight="bold" fontSize="24">${result.title}</text>
              <spacer></spacer>
              <text-button onpressed="removePlugin" data-name="${result.id}" foregroundColor="red">
                <row>
                  <icon size="16" icon="delete"></icon>
                  <text>移除</text>
                </row>
              </text-button>
            </row>
          </padding>
          <row mainAxisAlignment="start">
            <text fontWeight="bold" fontSize="16">关键词:</text>
            <padding left="12" right="12">
              <text color="black54">${selectedPlugin.config.keywords.join('、')}</text>
            </padding>
          </row>
        </column>
      </flutter-container>
    `
  },
  onResultTap(result) {
    if (result.id === 'select-plugin') {
      selectPluginFile().then(filePath => {
        if (!filePath) return;
        if (!filePath.endsWith('/plugin.json')) {
          return utils.toast('请选择plugin.json文件')
        }
        addDevPlugin(filePath, utils)
      })
    }
  },
  methods: {
    removePlugin(event) {
      const { name } = event.target.dataset;
      removeDevPlugin(name)
      utils.updateResults(getSearchResultList())
      utils.toast(`已成功移除插件${name}`)
    }
  }
})

module.exports = plugin