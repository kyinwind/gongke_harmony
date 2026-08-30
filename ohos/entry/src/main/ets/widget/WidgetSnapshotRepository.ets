import { preferences } from '@kit.ArkData';
import common from '@ohos.app.ability.common';
import { fileIo } from '@kit.CoreFileKit';

export const WIDGET_PREFERENCES_NAME = 'gongke_widget_snapshots';
export const WIDGET_INSTANCES_KEY = 'form_instances';
const TIP_CATALOG_FILE = 'today_tip_catalog.json';
const TIP_CATALOG_KEY = 'TodayTipCatalog';
const TIP_OVERRIDE_PREFIX = 'today_tip_override_';
const TIP_REFRESH_SEQUENCES_KEY = 'today_tip_refresh_sequences';

class WidgetFallbackData {
  schemaVersion: number = 1;
  generatedAt: string = new Date().toISOString();
  empty: boolean = true;
  stale: boolean = true;
  staleLevel: string = 'expired';
  staleDays: number = 0;
  staleMessage: string;
  dataDateLabel: string = '';
  todayDay: number = 0;
  monthLabel: string = '';
  weekdayLabel: string = '';
  message: string;
  title: string;

  constructor(formName: string, message: string) {
    this.message = message;
    this.staleMessage = message;
    this.title = formName;
    const now = new Date();
    this.todayDay = now.getDate();
    this.monthLabel = `${now.getMonth() + 1}月`;
    this.weekdayLabel = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][now.getDay()];
  }
}

interface TipRecordCatalogItem {
  recordId: number;
  recordJsonId: string;
  content: string;
  comments: string;
}

interface TipBookCatalogItem {
  bookId: number;
  bookName: string;
  bookSourceId: string;
  imageUri: string;
  records: TipRecordCatalogItem[];
}

interface TipCatalog {
  schemaVersion: number;
  generatedAt: string;
  date: string;
  mode: string;
  books: TipBookCatalogItem[];
}

interface TipCandidate {
  bookId: number;
  bookName: string;
  bookSourceId: string;
  imageUri: string;
  recordId: number;
  recordJsonId: string;
  content: string;
  comments: string;
}

export class WidgetSnapshotRepository {
  private store: preferences.Preferences;
  private context: common.Context;

  constructor(context: common.Context) {
    this.context = context;
    this.store = preferences.getPreferencesSync(context, { name: WIDGET_PREFERENCES_NAME });
  }

  read(formName: string): object {
    try {
      const raw = this.store.getSync(formName, '{}') as string;
      const value = JSON.parse(raw) as Record<string, Object>;
      const schemaVersion = value['schemaVersion'] as number ?? 0;
      const generatedAt = value['generatedAt'] as string ?? '';
      if (schemaVersion !== 1 || generatedAt.length === 0) {
        return this.fallback(formName, '请打开诵经助手更新卡片');
      }
      const timestamp = new Date(generatedAt).getTime();
      if (!Number.isFinite(timestamp)) return this.fallback(formName, '卡片更新时间异常，请打开应用更新');
      return this.decorateRuntime(value, formName);
    } catch (_) {
      return this.fallback(formName, '卡片数据异常，请打开应用更新');
    }
  }

  readForForm(formId: string, formName: string): object {
    const base = this.read(formName) as Record<string, Object>;
    if (formName !== 'TodayTipCard' || base['mode'] !== 'random') return base;
    try {
      const override = JSON.parse(
        this.store.getSync(`${TIP_OVERRIDE_PREFIX}${formId}`, '{}') as string,
      ) as Record<string, Object>;
      if (override['date'] !== base['date']) return base;
      const catalog = this.readTipCatalog();
      if (catalog === null || catalog.date !== base['date'] || catalog.mode !== 'random') return base;
      const recordId = override['recordId'] as number ?? 0;
      const bookId = override['bookId'] as number ?? 0;
      const selected = this.candidates(catalog).find((item: TipCandidate) =>
        item.bookId === bookId && item.recordId === recordId);
      if (selected === undefined) return base;
      // Keep the selected record stable, while rehydrating edited text, book
      // metadata and image from the newest catalog copied by the main app.
      this.applyCandidate(override, selected);
      return this.decorateRuntime(override, formName);
    } catch (_) {
      return base;
    }
  }

  refreshTip(formId: string): object {
    const base = this.readForForm(formId, 'TodayTipCard') as Record<string, Object>;
    if (base['mode'] !== 'random') return base;
    const catalog = this.readTipCatalog();
    if (catalog === null || catalog.mode !== 'random' || catalog.date !== base['date']) return base;
    const candidates = this.candidates(catalog);
    if (candidates.length < 2) return base;

    const sequences = this.refreshSequences();
    const sequence = (sequences[formId] ?? 0) + 1;
    sequences[formId] = sequence;
    let index = this.positiveModulo(
      this.stableHash(`${catalog.date}|${formId}|${sequence}`),
      candidates.length,
    );
    const currentRecordId = base['recordId'] as number ?? 0;
    const currentBookId = base['bookId'] as number ?? 0;
    if (candidates[index].recordId === currentRecordId && candidates[index].bookId === currentBookId) {
      index = (index + 1) % candidates.length;
    }
    const selected = candidates[index];
    const refreshed = JSON.parse(JSON.stringify(base)) as Record<string, Object>;
    this.applyCandidate(refreshed, selected);
    this.store.putSync(`${TIP_OVERRIDE_PREFIX}${formId}`, JSON.stringify(refreshed));
    this.store.putSync(TIP_REFRESH_SEQUENCES_KEY, JSON.stringify(sequences));
    this.store.flush();
    return this.decorateRuntime(refreshed, 'TodayTipCard');
  }

  addInstance(formId: string, formName: string): void {
    const instances = this.instances();
    instances[formId] = formName;
    this.store.putSync(WIDGET_INSTANCES_KEY, JSON.stringify(instances));
    this.store.flush();
  }

  removeInstance(formId: string): void {
    const instances = this.instances();
    const retained: Record<string, string> = {};
    Object.keys(instances).forEach((key: string) => {
      if (key !== formId) retained[key] = instances[key];
    });
    this.store.putSync(WIDGET_INSTANCES_KEY, JSON.stringify(retained));
    this.store.deleteSync(`${TIP_OVERRIDE_PREFIX}${formId}`);
    const sequences = this.refreshSequences();
    const retainedSequences: Record<string, number> = {};
    Object.keys(sequences).forEach((key: string) => {
      if (key !== formId) retainedSequences[key] = sequences[key];
    });
    this.store.putSync(TIP_REFRESH_SEQUENCES_KEY, JSON.stringify(retainedSequences));
    this.store.flush();
  }

  formName(formId: string): string {
    return this.instances()[formId] ?? '';
  }

  private instances(): Record<string, string> {
    try {
      return JSON.parse(
        this.store.getSync(WIDGET_INSTANCES_KEY, '{}') as string,
      ) as Record<string, string>;
    } catch (_) {
      return {};
    }
  }

  private readTipCatalog(): TipCatalog | null {
    try {
      const sharedText = this.store.getSync(TIP_CATALOG_KEY, '') as string;
      const text = sharedText.length > 0
        ? sharedText
        : fileIo.readTextSync(`${this.context.filesDir}/${TIP_CATALOG_FILE}`);
      const catalog = JSON.parse(text) as TipCatalog;
      if (catalog.schemaVersion !== 1 || catalog.date.length === 0) return null;
      return catalog;
    } catch (_) {
      return null;
    }
  }

  private candidates(catalog: TipCatalog): TipCandidate[] {
    const result: TipCandidate[] = [];
    catalog.books.forEach((book: TipBookCatalogItem) => {
      book.records.forEach((record: TipRecordCatalogItem) => {
        result.push({
          bookId: book.bookId,
          bookName: book.bookName,
          bookSourceId: book.bookSourceId,
          imageUri: book.imageUri ?? '',
          recordId: record.recordId,
          recordJsonId: record.recordJsonId ?? '',
          content: record.content,
          comments: record.comments ?? '',
        });
      });
    });
    return result;
  }

  private refreshSequences(): Record<string, number> {
    try {
      return JSON.parse(
        this.store.getSync(TIP_REFRESH_SEQUENCES_KEY, '{}') as string,
      ) as Record<string, number>;
    } catch (_) {
      return {};
    }
  }

  private applyCandidate(target: Record<string, Object>, selected: TipCandidate): void {
    target['bookId'] = selected.bookId;
    target['recordId'] = selected.recordId;
    target['bookName'] = selected.bookName;
    target['content'] = selected.content;
    target['imageUri'] = selected.imageUri;
    target['comments'] = selected.comments;
    target['bookSourceId'] = selected.bookSourceId;
    target['recordJsonId'] = selected.recordJsonId;
  }

  private stableHash(value: string): number {
    let hash = 0x811c9dc5;
    for (let index = 0; index < value.length; index++) {
      hash ^= value.charCodeAt(index);
      hash = Math.imul(hash, 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  private positiveModulo(value: number, divisor: number): number {
    return (value % divisor + divisor) % divisor;
  }

  private decorateRuntime(value: Record<string, Object>, formName: string): Record<string, Object> {
    const now = new Date();
    value['todayDay'] = now.getDate();
    value['monthLabel'] = `${now.getMonth() + 1}月`;
    value['weekdayLabel'] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][now.getDay()];

    const generatedAt = value['generatedAt'] as string ?? '';
    const generatedDate = new Date(generatedAt);
    const ageMs = Math.max(0, now.getTime() - generatedDate.getTime());
    const dayMs = 24 * 60 * 60 * 1000;
    const staleDays = Math.max(1, Math.floor(ageMs / dayMs));
    const staleLevel = ageMs > 3 * dayMs ? 'expired' : ageMs > dayMs ? 'warning' : 'normal';
    value['stale'] = staleLevel !== 'normal';
    value['staleLevel'] = staleLevel;
    value['staleDays'] = staleLevel === 'normal' ? 0 : staleDays;
    value['dataDateLabel'] = `${generatedDate.getMonth() + 1}月${generatedDate.getDate()}日`;
    value['staleMessage'] = staleLevel === 'normal' ? '' :
      `数据已${staleLevel === 'expired' ? '过期' : '超过'}${staleDays}天未更新 · 点击打开应用`;

    if (formName === 'GongKeCalendarCard') {
      const month = now.getMonth() + 1;
      const day = now.getDate();
      const runtimeDate = `${now.getFullYear()}-${month < 10 ? `0${month}` : month}-${day < 10 ? `0${day}` : day}`;
      const cells = value['cells'] as Array<Record<string, Object>> ?? [];
      cells.forEach((cell: Record<string, Object>) => {
        cell['isToday'] = cell['date'] === runtimeDate;
      });
      value['cells'] = cells;
    }
    return value;
  }

  private fallback(formName: string, message: string): object {
    return new WidgetFallbackData(formName, message);
  }
}
