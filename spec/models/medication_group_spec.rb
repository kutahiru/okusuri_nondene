require 'rails_helper'

RSpec.describe MedicationGroup, type: :model do
  describe "validations" do
    let(:medication_group) { build(:medication_group) }

    describe "group_name" do
      it "requires a group_name" do
        medication_group.group_name = nil
        expect(medication_group).not_to be_valid
        expect(medication_group.errors[:group_name]).to include("必須項目です。")
      end

      it "validates group_name length" do
        medication_group.group_name = "a" * 21
        expect(medication_group).not_to be_valid
        expect(medication_group.errors[:group_name]).to include("文字数が上限を超えています。")
      end

      it "accepts valid group_name" do
        medication_group.group_name = "有効なグループ名"
        expect(medication_group).to be_valid
      end
    end
  end

  describe "associations" do
    let(:medication_group) { create(:medication_group) }

    it "has many medication_group_users" do
      expect(medication_group).to respond_to(:medication_group_users)
    end

    it "has many users through medication_group_users" do
      expect(medication_group).to respond_to(:users)
    end

    it "has many medication_schedules" do
      expect(medication_group).to respond_to(:medication_schedules)
    end

    it "has one reward_condition" do
      expect(medication_group).to respond_to(:reward_condition)
    end

    it "has many reward_histories" do
      expect(medication_group).to respond_to(:reward_histories)
    end

    it "has many medication_group_invitations" do
      expect(medication_group).to respond_to(:medication_group_invitations)
    end

    it "has many medication_managements" do
      expect(medication_group).to respond_to(:medication_managements)
    end
  end

  describe ".create_group_with_user!" do
    let(:user) { create(:user) }
    let(:group_params) { { group_name: "新しいグループ" } }

    it "creates a medication group and adds user as medication_taker" do
      expect {
        MedicationGroup.create_group_with_user!(group_params, user.id)
      }.to change(MedicationGroup, :count).by(1)
        .and change(MedicationGroupUser, :count).by(1)

      group = MedicationGroup.last
      expect(group.group_name).to eq("新しいグループ")
      expect(group.medication_group_users.first.user).to eq(user)
      expect(group.medication_group_users.first.user_type).to eq("medication_taker")
    end

    it "returns the created group with preloaded associations" do
      result = MedicationGroup.create_group_with_user!(group_params, user.id)
      expect(result.medication_group_users.loaded?).to be true
    end

    it "raises error if group creation fails" do
      invalid_params = { group_name: nil }
      expect {
        MedicationGroup.create_group_with_user!(invalid_params, user.id)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
