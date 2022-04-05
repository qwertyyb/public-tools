const { default: axios } = require("axios");

const storeUrl = 'https://qwertyyb.github.io/public-tools/store.json'

const getPluginList = async () => {
  const res = await axios.get(storeUrl)
  return res.data
}

let cachedList = [];

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
                <elevated-button onPressed="download" data-name="${result.id}">
                  <row>
                    <icon size="16" icon="download"></icon>
                    <text>下载</text>
                  </row>
                </elevated-button>
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
    download(e) {
      // @todo 未完成
      console.log('download plugin: ', e)
      utils.toast('插件下载尚在开发中')
    },
  },
  onEnter() {},
  onExit() {},
})

module.exports = storePlugin;