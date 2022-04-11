const { default: axios } = require("axios");
const fs = require('fs')
const path = require('path')
const { exec } = require('child_process')
const { promisify } = require('util');
const { installPlugin } = require("../../core");
const { getPlugin } = require("../../core/plugin");

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
const downloadStatus = {}

let data = {
  selectedPlugin: null,
  downloadStatus: {},
  downloading: false,
  installed: false,
  needUpdate: false
}

const renderHtml = () => {
  with(data) {
    return `<div>
    <flutter-container>
      <column crossAxisAlignment="start">
        <row>
          <padding top="10" left="10" right="10" bottom="10">
            <image imageUrl="${selectedPlugin.icon}" width="80" height="80"></image>
          </padding>
          <column crossAxisAlignment="start">
            <text fontSize="16" fontWeight="bold">${selectedPlugin.title}</text>
            <text fontSize="12" color="black54">${selectedPlugin.subtitle}</text>
            <padding top="12">
              ${installed
                ? `<outlined-button disabled>
                    <row crossAxisAlignment="center">
                      <icon size="12"
                        icon="download"></icon>
                      <text fontSize="12">已安装</text>
                    </row>
                  <outlined-button>`
                : `<elevated-button onPressed="download" data-name="${selectedPlugin.id}">
                    <row crossAxisAlignment="center">
                      <icon size="12"
                        icon="${downloadStatus[selectedPlugin.id] ? 'downloading' : 'download'}"></icon>
                      <text fontSize="12">${
                        installed
                        ? needUpdate
                          ? '更新'
                          : '已安装'
                        : downloadStatus[selectedPlugin.id]
                          ? '下载中'
                          : '下载'}</text>
                    </row>
                  </elevated-button>`
                }
            </padding>
          </column>
        </row>
        <divider></divider>
        <padding top="10" left="10" bottom="10">
          <sizedbox height="160">
            <list-view scrollDirection="horizontal">
              <padding right="8">
                <image imageUrl="https://via.placeholder.com/240x160" width="240" height="160"></image>
              </padding>
              <padding right="8">
                <image imageUrl="https://via.placeholder.com/240x160" width="240" height="160"></image>
              </padding>
              <padding>
                <image imageUrl="https://via.placeholder.com/240x160" width="240" height="160"></image>
              </padding>
            </list-view>
          </sizedbox>
        </padding>
        <padding left="10">
          <text>${selectedPlugin.description}</text>
        </padding>
        <padding top="10" left="10" bottom="10">
          <row>
            <text fontSize="16" fontWeight="bold">关键词: </text>
            <text color="black54">${(selectedPlugin?.keywords || []).join('、')}</text>
          </row>
        </padding>
      </column>
    </flutter-container>
  </div>`
  }
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
    const downloading = downloadStatus[selectedPlugin.id]
    const plugin = getPlugin(result.id)
    const installed = !!plugin
    const needUpdate = plugin?.version !== selectedPlugin.version
    data = {
      ...data,
      selectedPlugin,
      downloading,
      installed,
      needUpdate
    }
    return renderHtml();
  },
  onResultTap(result) {
    return null;
  },
  methods: {
    async download(e) {
      console.log('download plugin: ', e)
      const { name } = e.target.dataset;
      if (data.downloadStatus[name]) return;
      data.downloadStatus[name] = true;
      utils.updatePreview(renderHtml())

      const [initErr] = await initPluginsDir()
      if (initErr) {
        utils.toast(initErr.message || initErr)
        data.downloadStatus[name] = false
        utils.updatePreview(renderHtml())
        return
      }
      // 使用pnpm进行下载
      const pnpmInstalled = await isPnpmInstalled()
      if (!pnpmInstalled) {
        const [installPnpmErr] = await installPnpm()
        if (installPnpmErr) {
          utils.toast(installPnpmErr.message || installPnpmErr)
          data.downloadStatus[name] = false
          utils.updatePreview(renderHtml())
        }
      }

      const [installErr, pluginPath] = await installPluginWithPnpm(name)
      if (installErr) {
        utils.toast(installErr.message || installErr)
        data.downloadStatus[name] = false
        utils.updatePreview(renderHtml())
        return
      }
      installPlugin(pluginPath)
      data.downloadStatus[name] = false
      data.installed = true
      utils.updatePreview(renderHtml())
      utils.toast('插件已下载')
    },
  },
  onEnter() {},
  onExit() {},
})

module.exports = storePlugin;