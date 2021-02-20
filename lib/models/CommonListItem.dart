class CommonListItem {
  String title;
  String subtitle;
  String icon;
  void Function(CommonListItem item, int index, List<CommonListItem> list)
      onSelect;
  void Function(CommonListItem item, int index, List<CommonListItem> list)
      onTap;

  CommonListItem(
      {this.title, this.subtitle, this.icon, this.onSelect, this.onTap});
}
