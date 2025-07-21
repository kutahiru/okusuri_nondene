require 'rails_helper'

RSpec.describe MedicationManagement, type: :model do
  describe "validations" do
    let(:medication_management) { build(:medication_management) }

    describe "medication_date" do
      it "requires a medication_date" do
        medication_management.medication_date = nil
        expect(medication_management).not_to be_valid
        expect(medication_management.errors[:medication_date]).to include("必須項目です。")
      end
    end

    describe "reminder_sent_count" do
      it "requires a reminder_sent_count" do
        medication_management.reminder_sent_count = nil
        expect(medication_management).not_to be_valid
        expect(medication_management.errors[:reminder_sent_count]).to include("必須項目です。")
      end

      it "validates numericality greater than or equal to 0" do
        medication_management.reminder_sent_count = -1
        expect(medication_management).not_to be_valid
        expect(medication_management.errors[:reminder_sent_count]).to include("0以上の値を入力してください。")
      end

      it "accepts valid reminder_sent_count" do
        medication_management.reminder_sent_count = 0
        expect(medication_management).to be_valid

        medication_management.reminder_sent_count = 5
        expect(medication_management).to be_valid
      end
    end
  end

  describe "associations" do
    let(:medication_management) { create(:medication_management) }

    it "belongs to medication_schedule" do
      expect(medication_management).to respond_to(:medication_schedule)
      expect(medication_management.medication_schedule).to be_a(MedicationSchedule)
    end

    it "belongs to medication_group" do
      expect(medication_management).to respond_to(:medication_group)
      expect(medication_management.medication_group).to be_a(MedicationGroup)
    end
  end

  describe "enums" do
    it "defines is_taken enum" do
      expect(MedicationManagement.is_takens).to eq({
        "not_taken" => false,
        "taken" => true
      })
    end

    it "responds to is_taken enum methods with prefix" do
      management = build(:medication_management)
      expect(management).to respond_to(:medication_not_taken?)
      expect(management).to respond_to(:medication_taken?)
    end

    it "sets correct enum values" do
      management = create(:medication_management, is_taken: false)
      expect(management.medication_not_taken?).to be true
      expect(management.medication_taken?).to be false

      management.update!(is_taken: true)
      expect(management.medication_not_taken?).to be false
      expect(management.medication_taken?).to be true
    end
  end

  describe "scopes" do
    describe ".for_month" do
      let!(:current_month_record) { create(:medication_management, medication_date: Date.current) }
      let!(:last_month_record) { create(:medication_management, medication_date: 1.month.ago) }
      let!(:next_month_record) { create(:medication_management, medication_date: 1.month.from_now) }

      it "returns records for current month by default" do
        results = MedicationManagement.for_month
        expect(results).to include(current_month_record)
        expect(results).not_to include(last_month_record, next_month_record)
      end

      it "returns records for specified month" do
        results = MedicationManagement.for_month(1.month.ago)
        expect(results).to include(last_month_record)
        expect(results).not_to include(current_month_record, next_month_record)
      end

      it "includes first and last day of month" do
        first_day = create(:medication_management, medication_date: Date.current.beginning_of_month)
        last_day = create(:medication_management, medication_date: Date.current.end_of_month)

        results = MedicationManagement.for_month
        expect(results).to include(first_day, last_day)
      end
    end

    describe ".with_rewards" do
      let(:group) { create(:medication_group) }
      let(:management) { create(:medication_management, medication_group: group, medication_date: Date.current) }

      before do
        # RewardHistoryファクトリが必要かもしれませんが、まずはSQLが動作することを確認
        management # レコードを作成
      end

      it "joins with reward_histories table" do
        results = MedicationManagement.with_rewards
        expect(results.to_sql).to include("LEFT JOIN reward_histories")
      end

      it "selects medication_managements columns and reward_name" do
        results = MedicationManagement.with_rewards
        expect(results.to_sql).to include("reward_histories.reward_name")
      end

      it "executes without error" do
        expect { MedicationManagement.with_rewards.to_a }.not_to raise_error
      end
    end
  end

  describe ".update_is_taken!" do
    let(:medication_management) { create(:medication_management, is_taken: false, completed_at: nil) }
    let(:line_service) { class_double("LineNotificationService") }

    before do
      stub_const("LineNotificationService", line_service)
      allow(line_service).to receive(:family_watcher_medication_taken_send_line_message)
    end

    context "when medication is not taken" do
      it "updates is_taken to true and sets completed_at" do
        freeze_time do
          expect {
            MedicationManagement.update_is_taken!(medication_management.id)
          }.to change { medication_management.reload.is_taken }.from("not_taken").to("taken")
            .and change { medication_management.reload.completed_at }.from(nil).to(Time.current)
        end
      end

      it "calls LineNotificationService to notify family watchers" do
        MedicationManagement.update_is_taken!(medication_management.id)

        expect(line_service).to have_received(:family_watcher_medication_taken_send_line_message)
          .with(medication_management, medication_management.medication_group.group_name)
      end
    end

    context "when medication is already taken" do
      let(:medication_management) { create(:medication_management, :taken) }
      let(:original_completed_at) { medication_management.completed_at }

      it "does not update the record" do
        expect {
          MedicationManagement.update_is_taken!(medication_management.id)
        }.not_to change { medication_management.reload.completed_at }
      end

      it "does not call LineNotificationService" do
        MedicationManagement.update_is_taken!(medication_management.id)

        expect(line_service).not_to have_received(:family_watcher_medication_taken_send_line_message)
      end

      it "returns early without processing" do
        expect(medication_management).not_to receive(:update!)
        MedicationManagement.update_is_taken!(medication_management.id)
      end
    end

    context "when medication_management does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          MedicationManagement.update_is_taken!(99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when update fails" do
      before do
        allow_any_instance_of(MedicationManagement).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "raises ActiveRecord::RecordInvalid" do
        expect {
          MedicationManagement.update_is_taken!(medication_management.id)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "does not call LineNotificationService when update fails" do
        begin
          MedicationManagement.update_is_taken!(medication_management.id)
        rescue ActiveRecord::RecordInvalid
          # Expected error
        end

        expect(line_service).not_to have_received(:family_watcher_medication_taken_send_line_message)
      end
    end
  end
end
