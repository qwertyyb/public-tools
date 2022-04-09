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
  if (fs.existsSync(pluginsDirPath)) return [null, null];
  fs.mkdirSync(pluginsDirPath, { recursive: true })
  return p(promisify(exec)('npm init -y'))
}

const isPnpmInstalled = async () => {
  const [err] = await p(promisify(exec)('pnpm --version'))
  return !err
}

const installPnpm = () => {
  return p(promisify(exec)('npm install -g pnpm'))
}

const installPluginWithPnpm = async (pluginName) => {
  const pluginNpmName = '@public-tools/plugin-' + pluginName
  const [err, result] = await p(promisify(exec)(`pnpm install ${pluginNpmName}`, {
    cwd: pluginsDirPath
  }))
  if (err) return [err, result]
  return [null, path.join(pluginsDirPath, 'node_modules', pluginNpmName, 'package.json')]
}

let cachedList = [];
const downloadStatus = {}

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
    const fullName = `@public-tools/plugin-${result.id}`
    const installed = !!getPlugin(fullName)
    console.log('installed', installed)
    return `<div>
      <flutter-container>
        <column crossAxisAlignment="start">
          <row>
            <padding top="10" left="10" right="10" bottom="10">
              <image imageUrl="${result.icon}" width="80" height="80"></image>
            </padding>
            <column crossAxisAlignment="start">
              <text fontSize="16" fontWeight="bold">${result.title}</text>
              <text fontSize="12" color="black54">${result.subtitle}</text>
              <padding top="12">
                ${installed
                  ? `<outlined-button disabled>
                      <row crossAxisAlignment="center">
                        <icon size="12"
                          icon="download"></icon>
                        <text fontSize="12">已安装</text>
                      </row>
                    <outlined-button>`
                  : `<elevated-button onPressed="download" data-name="${result.id}">
                      <row crossAxisAlignment="center">
                        <icon size="12"
                          icon="${downloading ? 'downloading' : 'download'}"></icon>
                        <text fontSize="12">${installed ? '已安装' : downloading ? '下载中' : '下载'}</text>
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
            <text>${result.description}</text>
          </padding>
          <padding top="10" left="10" bottom="10">
            <row>
              <text fontSize="16" fontWeight="bold">关键词: </text>
              <text color="black54">${(selectedPlugin?.keywords || []).join('、')}</text>
            </row>
          </padding>
        </column>
      </flutter-container>
    </div>`;
  },
  onResultTap(result) {
    return null;
  },
  methods: {
    async download(e) {
      console.log('download plugin: ', e)
      const { name } = e.target.dataset;
      if (downloadStatus[name]) return;
      downloadStatus[name] = true;
      utils.updateResults(cachedList);
      const [initErr] = await initPluginsDir()
      if (initErr) {
        utils.toast(initErr.message || initErr)
        downloadStatus[name] = false
        return
      }
      // 使用pnpm进行下载
      const pnpmInstalled = await isPnpmInstalled()
      if (!pnpmInstalled) {
        const [installPnpmErr] = await installPnpm()
        utils.toast(installPnpmErr.message || installPnpmErr)
        downloadStatus[name] = false
      }

      const [installErr, pluginPath] = await installPluginWithPnpm(name)
      if (installErr) {
        utils.toast(installErr.message || installErr)
        downloadStatus[name] = false
        return
      }
      installPlugin(pluginPath)
      downloadStatus[name] = false
      utils.toast('插件已下载')
      utils.updateResults(cachedList)
    },
  },
  onEnter() {},
  onExit() {},
})

module.exports = storePlugin;