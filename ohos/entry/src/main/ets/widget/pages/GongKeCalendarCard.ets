interface CalendarCell {
  date: string;
  day: number;
  lunar: string;
  inMonth: boolean;
  isToday: boolean;
  isWeekend: boolean;
  status: string;
  completionLabel: string;
}

@Entry
@Component
struct GongKeCalendarCard {
  @LocalStorageProp('monthTitle') monthTitle: string = '';
  @LocalStorageProp('todayDay') todayDay: number = 0;
  @LocalStorageProp('monthLabel') monthLabel: string = '';
  @LocalStorageProp('weekdayLabel') weekdayLabel: string = '';
  @LocalStorageProp('updatedText') updatedText: string = '';
  @LocalStorageProp('cells') cells: CalendarCell[] = [];
  @LocalStorageProp('message') message: string = '';
  @LocalStorageProp('staleLevel') staleLevel: string = 'normal';
  @LocalStorageProp('staleMessage') staleMessage: string = '';

  private staleColor(): string {
    return this.staleLevel === 'expired' ? '#C62828' : '#9A6700';
  }

  private staleBackground(): string {
    return this.staleLevel === 'expired' ? '#FDECEC' : '#FFF1C2';
  }

  private statusColor(cell: CalendarCell): string {
    if (!cell.inMonth) return '#00000000';
    if (cell.status === 'completed') return '#59CE7A';
    if (cell.status === 'pending') return '#FFD744';
    return '#FFFFFF';
  }

  private detailColor(cell: CalendarCell): string {
    if (cell.completionLabel === 'todo') return '#FF00FF';
    if (cell.completionLabel.endsWith('%') && cell.status === 'completed') return '#FFFFFF';
    return '#777777';
  }

  build() {
    Column({ space: 4 }) {
      Row() {
        Image($r('app.media.icon')).width(38).height(38).borderRadius(9)
        Column({ space: 1 }) {
          Text('功课日历').fontSize(21).fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.widget_text_primary'))
          Text(this.updatedText).fontSize(11)
            .fontColor(this.staleLevel === 'normal' ? $r('app.color.widget_text_secondary') : this.staleColor())
        }.alignItems(HorizontalAlign.Start).margin({ left: 8 })
        Blank()
        Text(this.todayDay.toString()).fontSize(36).fontWeight(FontWeight.Bold).fontColor('#087CF0')
        Column({ space: 0 }) {
          Text(this.monthLabel).fontSize(16).fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.widget_text_primary'))
          Text(this.weekdayLabel).fontSize(13).fontColor($r('app.color.widget_text_secondary'))
        }.alignItems(HorizontalAlign.Start).margin({ left: 5 })
      }.width('100%').height(48)
      if (this.staleLevel !== 'normal') {
        Row() {
          Text(`⚠ ${this.staleMessage}`).fontSize(10).fontWeight(FontWeight.Medium)
            .fontColor(this.staleColor()).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }.padding({ left: 7, right: 7 }).width('100%').height(20)
          .backgroundColor(this.staleBackground()).borderRadius(6)
      }
      Row() {
        ForEach(['一', '二', '三', '四', '五', '六', '日'], (day: string) => {
          Text(day).fontSize(12).fontColor(day === '六' || day === '日' ? '#F04B4B' : '#666666')
            .textAlign(TextAlign.Center).width('14.28%')
        })
      }.width('100%').height(18)
      if (this.cells.length === 0) {
        Text(this.message.length > 0 ? this.message : '暂无日历数据')
          .fontSize(18).fontColor($r('app.color.widget_text_secondary')).layoutWeight(1)
      } else {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.cells, (cell: CalendarCell) => {
            Column() {
              Column({ space: 0 }) {
                if (cell.inMonth) {
                  Text(cell.day.toString()).fontSize(13)
                    .fontWeight(cell.isToday ? FontWeight.Bold : FontWeight.Normal)
                    .fontColor(cell.isWeekend ? '#F04B4B' : $r('app.color.widget_text_primary'))
                  Text(cell.lunar).fontSize(7).fontColor('#777777').maxLines(1)
                  if (cell.completionLabel.length > 0) {
                    Text(cell.completionLabel)
                      .fontSize(8).fontWeight(cell.completionLabel.endsWith('%') ? FontWeight.Bold : FontWeight.Normal)
                      .fontColor(this.detailColor(cell)).maxLines(1)
                  }
                }
              }
              .justifyContent(FlexAlign.Center).width('100%').height('100%')
              .backgroundColor(this.statusColor(cell)).borderRadius(cell.inMonth ? 6 : 0)
              .border(cell.inMonth && cell.isToday ? { width: 2, color: '#087CF0' } : { width: 0 })
            }.width('14.28%').height(this.staleLevel === 'normal' ? 44 : 40)
              .padding({ left: 0.5, right: 0.5, top: 0.5, bottom: 0.5 })
          // isToday must participate in the key. When the card refreshes across
          // midnight ArkUI may otherwise reuse yesterday's node and retain its
          // old border while also drawing today's border.
          }, (cell: CalendarCell) => `${cell.date}-${cell.status}-${cell.completionLabel}-${cell.isToday}`)
        }.width('100%').layoutWeight(1).opacity(this.staleLevel === 'expired' ? 0.65 : 1)
      }
    }
    .padding(12).width('100%').height('100%').backgroundColor($r('app.color.widget_background')).borderRadius(24)
    .onClick(() => {
      postCardAction(this, { action: 'router', abilityName: 'EntryAbility', params: { route: 'homeTasks' } })
    })
  }
}
