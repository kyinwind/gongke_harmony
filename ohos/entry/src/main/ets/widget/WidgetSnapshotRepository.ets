import { preferences } from '@kit.ArkData';
import common from '@ohos.app.ability.common';

export const WIDGET_PREFERENCES_NAME = 'gongke_widget_snapshots';
export const WIDGET_INSTANCES_KEY = 'form_instances';

class WidgetFallbackData {
  schemaVersion: number = 1;
  generatedAt: string = new Date().toISOString();
  empty: boolean = true;
  stale: boolean = true;
  message: string;
  title: string;

  constructor(formName: string, message: string) {
    this.message = message;
    this.title = formName;
  }
}

interface SnapshotEnvelope {
  schemaVersion: number;
  generatedAt: string;
}

export class WidgetSnapshotRepository {
  private store: preferences.Preferences;

  constructor(context: common.Context) {
    this.store = preferences.getPreferencesSync(context, { name: WIDGET_PREFERENCES_NAME });
  }

  read(formName: string): object {
    try {
      const raw = this.store.getSync(formName, '{}') as string;
      const value = JSON.parse(raw) as SnapshotEnvelope;
      const schemaVersion = value.schemaVersion ?? 0;
      const generatedAt = value.generatedAt ?? '';
      if (schemaVersion !== 1 || generatedAt.length === 0) {
        return this.fallback(formName, '请打开诵经助手更新卡片');
      }
      const timestamp = new Date(generatedAt).getTime();
      if (!Number.isFinite(timestamp) || Date.now() - timestamp > 3 * 24 * 60 * 60 * 1000) {
        return this.fallback(formName, '数据已过期，请打开应用更新');
      }
      return value;
    } catch (_) {
      return this.fallback(formName, '卡片数据异常，请打开应用更新');
    }
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

  private fallback(formName: string, message: string): object {
    return new WidgetFallbackData(formName, message);
  }
}
