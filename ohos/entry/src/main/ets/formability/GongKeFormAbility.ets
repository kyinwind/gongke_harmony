import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { formProvider } from '@kit.FormKit';
import { WidgetSnapshotRepository } from '../widget/WidgetSnapshotRepository';

export default class GongKeFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const formName = want.parameters?.[formInfo.FormParam.NAME_KEY] as string ?? '';
    const formId = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string ?? '';
    const repository = new WidgetSnapshotRepository(this.context);
    repository.addInstance(formId, formName);
    return formBindingData.createFormBindingData(repository.read(formName));
  }

  async onUpdateForm(formId: string): Promise<void> {
    const repository = new WidgetSnapshotRepository(this.context);
    const formName = repository.formName(formId);
    if (formName.length > 0) {
      await formProvider.updateForm(
        formId,
        formBindingData.createFormBindingData(repository.read(formName)),
      );
    }
  }

  onFormEvent(formId: string, message: string): void {
    try {
      const event = JSON.parse(message) as Record<string, string>;
      if (event['action'] === 'refreshTip') {
        // Form Extension 不在此处后台启动 Flutter Engine。被动刷新
        // 重读已经过 schema/过期校验的当日稳定快照。
        this.onUpdateForm(formId);
      }
    } catch (_) {
      this.onUpdateForm(formId);
    }
  }

  onRemoveForm(formId: string): void {
    new WidgetSnapshotRepository(this.context).removeInstance(formId);
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY;
  }
}
