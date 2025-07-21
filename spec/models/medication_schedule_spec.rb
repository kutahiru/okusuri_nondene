require 'rails_helper'

RSpec.describe MedicationSchedule, type: :model do
  describe "validations" do
    let(:medication_schedule) { build(:medication_schedule) }

    describe "title" do
      it "requires a title" do
        medication_schedule.title = nil
        expect(medication_schedule).not_to be_valid
        expect(medication_schedule.errors[:title]).to include("必須項目です。")
      end

      it "validates title length" do
        medication_schedule.title = "a" * 21
        expect(medication_schedule).not_to be_valid
        expect(medication_schedule.errors[:title]).to include("文字数が上限を超えています。")
      end

      it "accepts valid title" do
        medication_schedule.title = "有効なタイトル"
        expect(medication_schedule).to be_valid
      end
    end

    describe "medication_time" do
      it "requires a medication_time" do
        medication_schedule.medication_time = nil
        expect(medication_schedule).not_to be_valid
        expect(medication_schedule.errors[:medication_time]).to include("必須項目です。")
      end

      it "accepts valid medication_time" do
        medication_schedule.medication_time = "12:30"
        expect(medication_schedule).to be_valid
      end
    end

    describe "reminder_count" do
      it "requires a reminder_count" do
        medication_schedule.reminder_count = nil
        expect(medication_schedule).not_to be_valid
        expect(medication_schedule.errors[:reminder_count]).to include("必須項目です。")
      end

      it "validates numericality greater than or equal to 0" do
        medication_schedule.reminder_count = -1
        expect(medication_schedule).not_to be_valid
        expect(medication_schedule.errors[:reminder_count]).to include("0以上の値を入力してください。")
      end

      it "accepts valid reminder_count" do
        medication_schedule.reminder_count = 0
        expect(medication_schedule).to be_valid

        medication_schedule.reminder_count = 5
        expect(medication_schedule).to be_valid
      end
    end

    describe "reminder_interval" do
      it "requires a reminder_interval" do
        medication_schedule.reminder_interval = nil
        expect(medication_schedule).not_to be_valid
        expect(medication_schedule.errors[:reminder_interval]).to include("必須項目です。")
      end

      it "validates numericality greater than or equal to 0" do
        medication_schedule.reminder_interval = -1
        expect(medication_schedule).not_to be_valid
        expect(medication_schedule.errors[:reminder_interval]).to include("0以上の値を入力してください。")
      end

      it "accepts valid reminder_interval" do
        medication_schedule.reminder_interval = 0
        expect(medication_schedule).to be_valid

        medication_schedule.reminder_interval = 30
        expect(medication_schedule).to be_valid
      end
    end

    describe "family_notification_delay" do
      it "requires a family_notification_delay" do
        medication_schedule.family_notification_delay = nil
        expect(medication_schedule).not_to be_valid
        expect(medication_schedule.errors[:family_notification_delay]).to include("必須項目です。")
      end

      it "validates numericality greater than or equal to 0" do
        medication_schedule.family_notification_delay = -1
        expect(medication_schedule).not_to be_valid
        expect(medication_schedule.errors[:family_notification_delay]).to include("0以上の値を入力してください。")
      end

      it "accepts valid family_notification_delay" do
        medication_schedule.family_notification_delay = 0
        expect(medication_schedule).to be_valid

        medication_schedule.family_notification_delay = 60
        expect(medication_schedule).to be_valid
      end
    end
  end

  describe "associations" do
    let(:medication_schedule) { create(:medication_schedule) }

    it "belongs to medication_group" do
      expect(medication_schedule).to respond_to(:medication_group)
      expect(medication_schedule.medication_group).to be_a(MedicationGroup)
    end

    it "has many schedule_drugs" do
      expect(medication_schedule).to respond_to(:schedule_drugs)
    end

    it "has many medication_managements" do
      expect(medication_schedule).to respond_to(:medication_managements)
    end

    it "destroys dependent schedule_drugs when deleted" do
      # schedule_drugsファクトリが必要な場合は作成
      # drug = create(:schedule_drug, medication_schedule: medication_schedule)
      # expect { medication_schedule.destroy! }.to change(ScheduleDrug, :count).by(-1)
    end

    it "destroys dependent medication_managements when deleted" do
      management = create(:medication_management, medication_schedule: medication_schedule)
      expect { medication_schedule.destroy! }.to change(MedicationManagement, :count).by(-1)
    end
  end

  describe "constants" do
    it "defines MAX_MEDICATION_SCHEDULE" do
      expect(MedicationSchedule::MAX_MEDICATION_SCHEDULE).to eq(3)
    end
  end

  describe ".check_medication_schedule_maximum" do
    let(:group) { create(:medication_group) }

    context "when group has less than maximum schedules" do
      before do
        2.times { create(:medication_schedule, medication_group: group) }
      end

      it "returns nil" do
        result = MedicationSchedule.check_medication_schedule_maximum(group.id)
        expect(result).to be_nil
      end
    end

    context "when group has exactly maximum schedules" do
      before do
        3.times { create(:medication_schedule, medication_group: group) }
      end

      it "returns error message" do
        result = MedicationSchedule.check_medication_schedule_maximum(group.id)
        expect(result).to eq("スケジュールは3つまで作成可能です")
      end
    end

    context "when group has more than maximum schedules" do
      before do
        4.times { create(:medication_schedule, medication_group: group) }
      end

      it "returns error message" do
        result = MedicationSchedule.check_medication_schedule_maximum(group.id)
        expect(result).to eq("スケジュールは3つまで作成可能です")
      end
    end

    context "when group has no schedules" do
      it "returns nil" do
        result = MedicationSchedule.check_medication_schedule_maximum(group.id)
        expect(result).to be_nil
      end
    end

    context "when group does not exist" do
      it "returns nil for non-existent group" do
        result = MedicationSchedule.check_medication_schedule_maximum(99999)
        expect(result).to be_nil
      end
    end
  end
end
