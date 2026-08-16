import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { formProvider } from '@kit.FormKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { WidgetSnapshotRepository } from '../widget/WidgetSnapshotRepository';

const LOG_DOMAIN = 0x0000;
const LOG_TAG = 'GongKeForm';

export default class GongKeFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const formName = want.parameters?.[formInfo.FormParam.NAME_KEY] as string ?? '';
    const formId = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string ?? '';
    const repository = new WidgetSnapshotRepository(this.context);
    repository.addInstance(formId, formName);
    return formBindingData.createFormBindingData(repository.readForForm(formId, formName));
  }

  async onUpdateForm(formId: string): Promise<void> {
    const repository = new WidgetSnapshotRepository(this.context);
    const formName = repository.formName(formId);
    if (formName.length > 0) {
      await formProvider.updateForm(
        formId,
        formBindingData.createFormBindingData(repository.readForForm(formId, formName)),
      );
    }
  }

  onFormEvent(formId: string, message: string): void {
    hilog.info(LOG_DOMAIN, LOG_TAG, 'onFormEvent formId=%{public}s message=%{public}s', formId, message);
    try {
      let action = message;
      if (message.startsWith('{')) {
        const event = JSON.parse(message) as Record<string, string>;
        action = event['message'] ?? event['action'] ?? '';
      }
      if (action === 'refreshTip') {
        const repository = new WidgetSnapshotRepository(this.context);
        formProvider.updateForm(
          formId,
          formBindingData.createFormBindingData(repository.refreshTip(formId)),
        ).then(() => {
          hilog.info(LOG_DOMAIN, LOG_TAG, 'refreshTip updated formId=%{public}s', formId);
        }).catch((error: Error) => {
          hilog.error(LOG_DOMAIN, LOG_TAG, 'refreshTip update failed: %{public}s', error.message);
        });
      }
    } catch (error) {
      hilog.error(LOG_DOMAIN, LOG_TAG, 'onFormEvent parse failed: %{public}s', JSON.stringify(error));
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
