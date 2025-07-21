require 'rails_helper'

RSpec.describe MedicationGroupUser, type: :model do
  describe "validations" do
    let(:medication_group_user) { build(:medication_group_user) }

    describe "user_type" do
      it "requires a user_type" do
        medication_group_user.user_type = nil
        expect(medication_group_user).not_to be_valid
        expect(medication_group_user.errors[:user_type]).to include("必須項目です。")
      end

      it "accepts valid user_type values" do
        medication_group_user.user_type = "medication_taker"
        expect(medication_group_user).to be_valid

        medication_group_user.user_type = "family_watcher"
        expect(medication_group_user).to be_valid
      end
    end

    describe "user_id uniqueness" do
      it "validates uniqueness of user_id scoped to medication_group_id" do
        existing_user = create(:medication_group_user)
        duplicate_user = build(
          :medication_group_user,
          user: existing_user.user,
          medication_group: existing_user.medication_group
        )

        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:user_id]).to include("既に使用されています。")
      end
    end

    describe "medication_taker uniqueness in group" do
      let(:group) { create(:medication_group) }

      it "allows only one medication_taker per group" do
        create(:medication_group_user, medication_group: group, user_type: "medication_taker")
        duplicate_taker = build(:medication_group_user, medication_group: group, user_type: "medication_taker")

        expect(duplicate_taker).not_to be_valid
        expect(duplicate_taker.errors[:user_type]).to include("は同じグループ内で重複できません")
      end

      it "allows multiple family_watchers per group" do
        create(:medication_group_user, medication_group: group, user_type: "family_watcher")
        another_watcher = build(:medication_group_user, medication_group: group, user_type: "family_watcher")

        expect(another_watcher).to be_valid
      end
    end

    describe "user group limit validation" do
      it "validates that user can join maximum 3 groups" do
        user = create(:user)
        3.times { create(:medication_group_user, user: user) }

        fourth_group_user = build(:medication_group_user, user: user)
        expect(fourth_group_user).not_to be_valid
        expect(fourth_group_user.errors[:base]).to include("ユーザーが参加できるグループは3つまでです。")
      end
    end

    describe "group user limit validation" do
      it "validates that group can have maximum 4 users" do
        group = create(:medication_group)
        create(:medication_group_user, medication_group: group, user_type: "medication_taker")
        3.times { create(:medication_group_user, :family_watcher, medication_group: group) }

        fifth_user = build(:medication_group_user, :family_watcher, medication_group: group)
        expect(fifth_user).not_to be_valid
        expect(fifth_user.errors[:base]).to include("1グループにユーザーは4人までです。")
      end
    end
  end

  describe "associations" do
    let(:medication_group_user) { create(:medication_group_user) }

    it "belongs to medication_group" do
      expect(medication_group_user).to respond_to(:medication_group)
      expect(medication_group_user.medication_group).to be_a(MedicationGroup)
    end

    it "belongs to user" do
      expect(medication_group_user).to respond_to(:user)
      expect(medication_group_user.user).to be_a(User)
    end
  end

  describe "enums" do
    it "defines user_type enum" do
      expect(MedicationGroupUser.user_types).to eq({
        "medication_taker" => "medication_taker",
        "family_watcher" => "family_watcher"
      })
    end

    it "responds to user_type enum methods" do
      user = build(:medication_group_user)
      expect(user).to respond_to(:medication_taker?)
      expect(user).to respond_to(:family_watcher?)
    end
  end

  describe ".add_user_to_group!" do
    let(:group) { create(:medication_group) }
    let(:user) { create(:user) }

    context "when adding medication_taker" do
      it "creates medication_group_user with medication_taker type" do
        expect {
          MedicationGroupUser.add_user_to_group!(group.id, user.id, "medication_taker")
        }.to change(MedicationGroupUser, :count).by(1)

        created_user = MedicationGroupUser.last
        expect(created_user.medication_group).to eq(group)
        expect(created_user.user).to eq(user)
        expect(created_user.user_type).to eq("medication_taker")
      end

      it "changes existing medication_taker to family_watcher" do
        existing_taker = create(:medication_group_user, medication_group: group, user_type: "medication_taker")

        MedicationGroupUser.add_user_to_group!(group.id, user.id, "medication_taker")

        existing_taker.reload
        expect(existing_taker.user_type).to eq("family_watcher")
      end
    end

    context "when adding family_watcher" do
      it "creates medication_group_user with family_watcher type" do
        expect {
          MedicationGroupUser.add_user_to_group!(group.id, user.id, "family_watcher")
        }.to change(MedicationGroupUser, :count).by(1)

        created_user = MedicationGroupUser.last
        expect(created_user.user_type).to eq("family_watcher")
      end
    end
  end

  describe ".update_family_watcher_in_group!" do
    let(:group) { create(:medication_group) }

    it "updates all medication_takers in group to family_watcher" do
      taker1 = create(:medication_group_user, medication_group: group, user_type: "medication_taker")
      watcher = create(:medication_group_user, medication_group: group, user_type: "family_watcher")

      MedicationGroupUser.update_family_watcher_in_group!(group.id)

      taker1.reload
      watcher.reload
      expect(taker1.user_type).to eq("family_watcher")
      expect(watcher.user_type).to eq("family_watcher")
    end
  end

  describe ".update_medication_taker!" do
    it "updates specified user to medication_taker" do
      group_user = create(:medication_group_user, user_type: "family_watcher")

      MedicationGroupUser.update_medication_taker!(group_user.id)

      group_user.reload
      expect(group_user.user_type).to eq("medication_taker")
    end
  end

  describe ".update_medication_taker_in_group!" do
    let(:group) { create(:medication_group) }

    it "changes medication taker in group with transaction" do
      old_taker = create(:medication_group_user, medication_group: group, user_type: "medication_taker")
      new_taker = create(:medication_group_user, medication_group: group, user_type: "family_watcher")

      MedicationGroupUser.update_medication_taker_in_group!(group.id, new_taker.id)

      old_taker.reload
      new_taker.reload
      expect(old_taker.user_type).to eq("family_watcher")
      expect(new_taker.user_type).to eq("medication_taker")
    end
  end

  describe ".find_family_watchers" do
    let(:group) { create(:medication_group) }

    it "returns family_watchers for the specified group" do
      taker = create(:medication_group_user, medication_group: group, user_type: "medication_taker")
      watcher1 = create(:medication_group_user, medication_group: group, user_type: "family_watcher")
      watcher2 = create(:medication_group_user, medication_group: group, user_type: "family_watcher")
      other_group_watcher = create(:medication_group_user, user_type: "family_watcher")

      watchers = MedicationGroupUser.find_family_watchers(group.id)

      expect(watchers.count).to eq(2)
      expect(watchers).to include(watcher1, watcher2)
      expect(watchers).not_to include(taker, other_group_watcher)
    end

    it "preloads user association" do
      create(:medication_group_user, medication_group: group, user_type: "family_watcher")
      watchers = MedicationGroupUser.find_family_watchers(group.id)

      expect(watchers.first.association(:user).loaded?).to be true
    end
  end
end
