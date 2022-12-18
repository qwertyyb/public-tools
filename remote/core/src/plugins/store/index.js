const { default: axios } = require("axios");
const fs = require('fs')
const path = require('path')
const { exec } = require('child_process')
const { promisify } = require('util');
const { getPlugin, reloadPlugin } = require("../../core/plugin");

const p = (promise) => promise.then(res => ([null, res])).catch(err => ([err, null]))

const storeUrl = 'https://qwertyyb.github.io/public-tools/store.json'
const pluginsDirPath = process.env.HOME + '/Library/Application Support/cn.qwertyyb.public/plugins'

const getPluginList = async () => {
  const res = await axios.get(storeUrl)
  return res.data
}

const initPluginsDir = () => {
  if (fs.existsSync(path.join(pluginsDirPath, './package.json'))) return [null, null];
  if (!fs.existsSync(pluginsDirPath)) {
    fs.mkdirSync(pluginsDirPath, { recursive: true })
  }
  return p(promisify(exec)('npm init -y', {
    cwd: pluginsDirPath
  }))
}

const isPnpmInstalled = async () => {
  const [err] = await p(promisify(exec)('pnpm --version', {
    cwd: pluginsDirPath
  }))
  return !err
}

const installPnpm = () => {
  return p(promisify(exec)('npm install -g pnpm', {
    cwd: pluginsDirPath
  }))
}

const installPluginWithPnpm = async (pluginName) => {
  let pluginNpmName = pluginName
  if (!pluginName.startsWith('@public-tools/plugin-')) {
    pluginNpmName = '@public-tools/plugin-' + pluginName
  }
  const [err, result] = await p(promisify(exec)(`pnpm install ${pluginNpmName}@latest`, {
    cwd: pluginsDirPath
  }))
  console.log(err, result);
  if (err) return [err, result]
  return [null, path.join(pluginsDirPath, 'node_modules', pluginNpmName, 'package.json')]
}

let cachedList = [];

const Status = {
  DOWNLOADING: 'downloading',
  INSTALLED: 'installed',
  NEED_UPDATE: 'need_update',
  NEED_INSTALL: 'need_install',
}

let data = {
  selectedPlugin: null,
  localPlugin: null,
  downloadStatus: {},
  status: Status.NEED_INSTALL,
}

const template = fs.readFileSync(path.join(__dirname, './preview.html'), 'utf8')
const renderHtml = (state = data) => {
  console.log(state)
  const func = new Function('state', `with(state) { return \`${template}\` }`)
  return func(state)
}

const storePlugin = utils => ({
  async onSearch(keyword) {
    const query = keyword || ''
    const { updateTime, plugins } = await getPluginList()
      .catch(err => {
        utils.toast(err.message)
        return { updateTime: 0, plugins: [] }
      })
    const list = plugins.map(plugin => {
      return {
        ...plugin,
        id: plugin.name,
        title: plugin.title,
        subtitle: plugin.subtitle || plugin.title,
        description: plugin.description,
        icon: plugin.icon,
        keywords: plugin.keywords || ['clipboard', 'copy', 'paste', '剪切板历史'],
      }
    }).filter(plugin => plugin.id.includes(query) || plugin.title.includes(query))
    cachedList = list
    return list
  },
  onResultSelected(result) {
    const selectedPlugin = cachedList.find(item => item.id === result.id)
    const downloading = data.downloadStatus[selectedPlugin.id]
    const plugin = getPlugin(result.id)
    const installed = !!plugin
    const needUpdate = plugin?.version !== selectedPlugin.version
    const status = downloading
      ? Status.DOWNLOADING
      : (installed
          ? (needUpdate
              ? Status.NEED_UPDATE
              : Status.INSTALLED)
          : Status.NEED_INSTALL)
    data = {
      ...data,
      selectedPlugin,
      downloading,
      installed,
      needUpdate,
      status,
      localPlugin: plugin,
    }
    console.log(data);
    return renderHtml(data);
  },
  onResultTap(result) {
    return null;
  },
  methods: {
    async download(dataset) {
      console.log('download plugin: ', dataset)
      const { name } = dataset;
      if (data.downloadStatus[name]) return;
      data.downloadStatus[name] = true;
      data.status = Status.DOWNLOADING;
      utils.updatePreview(renderHtml())

      const [initErr] = await initPluginsDir()
      if (initErr) {
        utils.toast(initErr.message || initErr)
        data.status = Status.NEED_INSTALL
        utils.updatePreview(renderHtml())
        return
      }
      // 使用pnpm进行下载
      const pnpmInstalled = await isPnpmInstalled()
      if (!pnpmInstalled) {
        const [installPnpmErr] = await installPnpm()
        if (installPnpmErr) {
          utils.toast(installPnpmErr.message || installPnpmErr)
          data.status = Status.NEED_INSTALL
          utils.updatePreview(renderHtml())
        }
      }

      const [installErr, pluginPath] = await installPluginWithPnpm(name)
      if (installErr) {
        utils.toast(installErr.message || installErr)
        data.status = Status.NEED_INSTALL
        utils.updatePreview(renderHtml())
        return
      }
      reloadPlugin(pluginPath)
      data.status = Status.INSTALLED
      data.localPlugin = getPlugin(name)
      utils.updatePreview(renderHtml())
      utils.toast('插件已下载')
    },
  },
  onEnter() {},
  onExit() {},
})

module.exports = storePlugin;