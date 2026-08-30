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
  @LocalStorageProp('staleLevel') staleLevel: string = 'normal';
  @LocalStorageProp('staleDays') staleDays: number = 0;
  @LocalStorageProp('staleMessage') staleMessage: string = '';
  @LocalStorageProp('dataDateLabel') dataDateLabel: string = '';

  private staleColor(): string {
    return this.staleLevel === 'expired' ? '#C62828' : '#9A6700';
  }

  private staleBackground(): string {
    return this.staleLevel === 'expired' ? '#FDECEC' : '#FFF1C2';
  }

  build() {
    Column({ space: 4 }) {
      Row() {
        Image($r('app.media.icon')).width(38).height(38).borderRadius(9)
        Column({ space: 1 }) {
          Text('今日功课').fontSize(21).fontWeight(FontWeight.Bold).fontColor($r('app.color.widget_text_primary'))
          Text(this.updatedText).fontSize(11)
            .fontColor(this.staleLevel === 'normal' ? $r('app.color.widget_text_secondary') : this.staleColor())
        }.alignItems(HorizontalAlign.Start).margin({ left: 8 })
        Blank()
        Text(this.todayDay.toString()).fontSize(36).fontWeight(FontWeight.Bold).fontColor('#087CF0')
        Column({ space: 0 }) {
          Text(this.monthLabel).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.widget_text_primary'))
          Text(this.weekdayLabel).fontSize(13).fontColor($r('app.color.widget_text_secondary'))
        }.alignItems(HorizontalAlign.Start).margin({ left: 5 })
      }.width('100%').height(48)
      if (this.staleLevel !== 'normal') {
        Row() {
          Text('⚠').fontSize(13).fontColor(this.staleColor())
          Text(`截至${this.dataDateLabel}${this.completed ? '已完成' : '进行中'} · ${this.staleDays}天未更新`)
            .fontSize(11).fontWeight(FontWeight.Medium).fontColor(this.staleColor())
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ left: 4 })
        }.padding({ left: 7, right: 7 }).width('100%').height(22)
          .backgroundColor(this.staleBackground()).borderRadius(6)
      } else {
        Row() {
          Text('今天您的功课').fontSize(13).fontColor($r('app.color.widget_text_secondary'))
          Blank()
          Text(this.completed ? '已完成' : '进行中')
            .fontSize(14).fontColor(this.completed ? '#2EAD62' : '#E39422')
        }.width('100%').height(20)
      }
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
          }.width('100%').opacity(this.staleLevel === 'expired' ? 0.65 : 1)
        }, (item: TaskCardItem) => `${item.id}-${item.isComplete}-${item.currentCount}-${item.count}`)
      }
    }
    .padding(12).width('100%').height('100%').backgroundColor($r('app.color.widget_background')).borderRadius(24)
    .onClick(() => {
      postCardAction(this, { action: 'router', abilityName: 'EntryAbility', params: { route: 'homeTasks' } })
    })
  }
}
