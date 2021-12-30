const { default: axios } = require("axios");
const markdown = require('markdown').markdown
const createPlugin = require("../core/plugin");

const getPluginList = async () => {
  const res = await axios.get('https://qwertyyb.github.io/YPaste-flutter/plugins.json')
  return res.data
}

let list = [];


const plugin = createPlugin('plugin store', {
  title: '插件市场',
  subtitle: '搜索、下载、升级插件',
  icon: 'https://img.icons8.com/color/50/000000/joomla.png'
})

plugin.onKeywordChange(async ({ keyword }) => {
  const { updateTime, pluginList } = await getPluginList()
  list = pluginList
  const filteredList = list.map(item => {
    return {
      id: item.name,
      title: item.title || '',
      subtitle: item.description || '',
      icon: item.icon || ''
    }
  }).filter(item => item.id && item.title && item.subtitle && item.icon)
  return plugin.updateList(keyword, filteredList)
})

plugin.onSelect((item) => {
  const id = item.id.split('-').pop()
  const target = list.find(i => i.name === id)
  if (!target) return
  console.log(target)
  const html = markdown.toHTML(target.intro)
  plugin.updatePreview({ html })
})

module.exports = plugin;