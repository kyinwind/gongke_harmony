interface TaskCardItem {
  id: number;
  name: string;
  count: number;
  currentCount: number;
  isComplete: boolean;
}

@Entry
@Component
struct TodayTasksCard {
  @LocalStorageProp('date') date: string = '';
  @LocalStorageProp('updatedText') updatedText: string = '';
  @LocalStorageProp('todayDay') todayDay: number = 0;
  @LocalStorageProp('monthLabel') monthLabel: string = '';
  @LocalStorageProp('weekdayLabel') weekdayLabel: string = '';
  @LocalStorageProp('completed') completed: boolean = false;
  @LocalStorageProp('items') items: TaskCardItem[] = [];
  @LocalStorageProp('message') message: string = '';

  build() {
    Column({ space: 4 }) {
      Row() {
        Image($r('app.media.icon')).width(38).height(38).borderRadius(9)
        Column({ space: 1 }) {
          Text('今日功课').fontSize(21).fontWeight(FontWeight.Bold).fontColor($r('app.color.widget_text_primary'))
          Text(this.updatedText).fontSize(11).fontColor($r('app.color.widget_text_secondary'))
        }.alignItems(HorizontalAlign.Start).margin({ left: 8 })
        Blank()
        Text(this.todayDay.toString()).fontSize(36).fontWeight(FontWeight.Bold).fontColor('#087CF0')
        Column({ space: 0 }) {
          Text(this.monthLabel).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.widget_text_primary'))
          Text(this.weekdayLabel).fontSize(13).fontColor($r('app.color.widget_text_secondary'))
        }.alignItems(HorizontalAlign.Start).margin({ left: 5 })
      }.width('100%').height(48)
      Row() {
        Text('今天您的功课').fontSize(13).fontColor($r('app.color.widget_text_secondary'))
        Blank()
        Text(this.completed ? '已完成' : '进行中')
          .fontSize(14).fontColor(this.completed ? '#2EAD62' : '#E39422')
      }.width('100%').height(20)
      if (this.items.length === 0) {
        Text(this.message.length > 0 ? this.message : '今日暂无功课')
          .fontSize(17).fontColor($r('app.color.widget_text_secondary')).layoutWeight(1)
      } else {
        ForEach(this.items, (item: TaskCardItem) => {
          Row() {
            Text(item.isComplete ? '✓' : '○')
              .fontSize(18).fontColor(item.isComplete ? '#2EAD62' : '#999999')
            Text(item.name).fontSize(16).fontColor($r('app.color.widget_text_primary')).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1).margin({ left: 8 })
            Text(`${item.currentCount}/${item.count}`).fontSize(14).fontColor('#666666')
          }.width('100%')
        }, (item: TaskCardItem) => `${item.id}-${item.isComplete}-${item.currentCount}-${item.count}`)
      }
    }
    .padding(12).width('100%').height('100%').backgroundColor($r('app.color.widget_background')).borderRadius(24)
    .onClick(() => {
      postCardAction(this, { action: 'router', abilityName: 'EntryAbility', params: { route: 'tasks' } })
    })
  }
}
