const { default: axios } = require("axios");
const markdown = require('markdown').markdown
const createPlugin = require("../core/plugin");

const getPluginList = async () => {
  const res = await axios.get('https://qwertyyb.github.io/YPaste-flutter/plugins.json')
  return res.data
}

const storePlugin = createPlugin(utils => ({
  id: 'store',
  title: '插件列表',
  subtitle: '插件列表',
  description: '插件列表',
  mode: 'listView',
  keywords: ['插件列表', 'plugins store'],
  icon: 'https://img.icons8.com/color/50/000000/joomla.png',

  async onSearch(keyword) {
    const query = keyword || ''
    const { updateTime, pluginList } = await getPluginList()
    const list = pluginList.map(plugin => {
      return {
        id: plugin.name,
        title: plugin.title,
        subtitle: plugin.subtitle || plugin.title,
        description: plugin.description,
        icon: plugin.icon,
      }
    }).filter(plugin => plugin.id.includes(query) || plugin.title.includes(query))
    return list
  },
  onResultSelected(result) {
    const intro = markdown.toHTML(result.description || `# ${title}\n # ${subtitle}`)
    return `<div>
      <flutter-container>
        <row>
          <spacer></spacer>
          <text-button onpressed="downloadPlugin" data-id="${result.id}">
            <row>
              <icon size="16"></icon>
              <text>下载</text>
            </row>
          </text-button>
        </row>
      </flutter-container>
      <div>${intro}</div>
    </div>`;
  },
  onResultTap(result) {
    return null;
  },
  downloadPlugin() {
    console.log('download plugin')
  },
  onEnter() {},
  onExit() {},
}))

module.exports = storePlugin;