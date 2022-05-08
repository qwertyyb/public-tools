interface PluginResult {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  icon: string;
}

interface PublicPluginMethods {
  // 当进入插件页面时调用
  onEnter: () => void
  // 当离开插件页面时调用
  onExit: () => void
  /**
   * 在插件中搜索时调用
   * @param keyword 关键词
   * @return 搜索结果
   */
  onSearch: (keyword: string) => Promise<PluginResult[]>
  /**
   * 当在插件中选择某个搜索结果时调用
   * @param result 搜索结果, 具体结构参考PluginResult
   * @return 返回Promise<string>，返回的字符串将作为搜索结果的详情显示在右侧
   */
  onResultSelected: (result: PluginResult) => Promise<string>
  /**
   * 当在插件中点击某个搜索结果时调用
   * @param result 搜索结果, 具体结构参考PluginResult
   */
  onResultTap: (result: PluginResult) => void
}

interface Utils {
  toast: (message: string) => Promise
  hideApp: () => Promise
  showApp: () => Promise
  updateResults: (results: PluginResult[]) => Promise
  updatePreview: (preview: string) => Promise
}

interface PublicPlugin {
  (utils: Utils) : PublicPluginMethods
}