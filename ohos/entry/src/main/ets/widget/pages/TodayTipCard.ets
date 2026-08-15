@Entry
@Component
struct TodayTipCard {
  @LocalStorageProp('content') content: string = '';
  @LocalStorageProp('bookName') bookName: string = '';
  @LocalStorageProp('imageUri') imageUri: string = '';
  @LocalStorageProp('date') date: string = '';
  @LocalStorageProp('updatedText') updatedText: string = '';
  @LocalStorageProp('todayDay') todayDay: number = 0;
  @LocalStorageProp('monthLabel') monthLabel: string = '';
  @LocalStorageProp('weekdayLabel') weekdayLabel: string = '';
  @LocalStorageProp('recordId') recordId: number = 0;
  @LocalStorageProp('bookId') bookId: number = 0;
  @LocalStorageProp('message') message: string = '';

  build() {
    Column({ space: 8 }) {
      Row() {
        Image(this.imageUri.length > 0 ? this.imageUri : $r('app.media.icon'))
          .width(38).height(38).borderRadius(9).objectFit(ImageFit.Cover)
        Column({ space: 1 }) {
          Text('今日开示').fontSize(21).fontWeight(FontWeight.Bold).fontColor($r('app.color.widget_text_primary'))
          Text(this.updatedText).fontSize(11).fontColor($r('app.color.widget_text_secondary'))
        }.alignItems(HorizontalAlign.Start).margin({ left: 8 })
        Blank()
        Text(this.todayDay.toString()).fontSize(36).fontWeight(FontWeight.Bold).fontColor('#087CF0')
        Column({ space: 0 }) {
          Text(this.monthLabel).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.widget_text_primary'))
          Text(this.weekdayLabel).fontSize(13).fontColor($r('app.color.widget_text_secondary'))
        }.alignItems(HorizontalAlign.Start).margin({ left: 5 })
      }.width('100%').height(48)
      Text(this.content.length > 0 ? this.content :
        (this.message.length > 0 ? this.message : '暂无开示'))
        .fontSize(22).lineHeight(34).maxLines(7)
        .fontColor($r('app.color.widget_text_primary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
      Row() {
        Button('↻').fontSize(18).width(34).height(34).type(ButtonType.Circle).backgroundColor('#F2EBDD')
          .fontColor('#6B5A3A').onClick(() => {
            postCardAction(this, { action: 'message', params: { action: 'refreshTip' } })
          })
        Blank()
        Text(this.bookName.length > 0 ? `《${this.bookName}》` : '《诵经助手》')
          .fontSize(16).fontColor($r('app.color.widget_text_secondary'))
      }.width('100%')
    }
    .padding(12).width('100%').height('100%').backgroundColor($r('app.color.widget_tip_background')).borderRadius(24)
    .onClick(() => {
      postCardAction(this, {
        action: 'router', abilityName: 'EntryAbility',
        params: { route: 'tips', bookId: this.bookId, recordId: this.recordId }
      })
    })
  }
}
