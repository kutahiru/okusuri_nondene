require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    let(:user) { build(:user) }

    describe "user_name" do
      it "requires a user_name" do
        user.user_name = nil
        expect(user).not_to be_valid
        expect(user.errors[:user_name]).to include("必須項目です。")
      end

      it "validates user_name length" do
        user.user_name = "a" * 21
        expect(user).not_to be_valid
        expect(user.errors[:user_name]).to include("文字数が上限を超えています。")
      end

      it "accepts valid user_name" do
        user.user_name = "有効なユーザー名"
        expect(user).to be_valid
      end
    end

    describe "provider" do
      it "requires a provider" do
        user.provider = nil
        expect(user).not_to be_valid
        expect(user.errors[:provider]).to include("必須項目です。")
      end
    end

    describe "uid" do
      it "requires a uid" do
        user.uid = nil
        expect(user).not_to be_valid
        expect(user.errors[:uid]).to include("必須項目です。")
      end
    end

    describe "provider and uid uniqueness" do
      it "validates uniqueness of provider scoped to uid" do
        create(:user, provider: "line", uid: "12345")
        duplicate_user = build(:user, provider: "line", uid: "12345")

        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:provider]).to include("既に使用されています。")
      end

      it "allows same uid with different provider" do
        create(:user, provider: "line", uid: "12345")
        different_provider_user = build(:user, provider: "google", uid: "12345")

        expect(different_provider_user).to be_valid
      end
    end
  end

  describe "associations" do
    let(:user) { create(:user) }

    it "has many medication_group_users" do
      expect(user).to respond_to(:medication_group_users)
    end

    it "has many medication_groups through medication_group_users" do
      expect(user).to respond_to(:medication_groups)
    end

    it "has many medication_histories" do
      expect(user).to respond_to(:medication_histories)
    end

    it "has many medication_group_invitations" do
      expect(user).to respond_to(:medication_group_invitations)
    end

    it "has many medication_schedules through medication_groups" do
      expect(user).to respond_to(:medication_schedules)
    end

    it "has many reward_conditions through medication_groups" do
      expect(user).to respond_to(:reward_conditions)
    end
  end

  describe "enums" do
    it "defines description_read enum" do
      expect(User.description_reads).to eq({ "not_read" => false, "read" => true })
    end

    it "responds to description_read enum methods" do
      user = build(:user)
      expect(user).to respond_to(:description_not_read?)
      expect(user).to respond_to(:description_read?)
    end
  end

  describe "#get_user_groups" do
    let(:user) { create(:user) }
    let!(:medication_group1) { create(:medication_group) }
    let!(:medication_group2) { create(:medication_group) }

    before do
      create(:medication_group_user, user: user, medication_group: medication_group1)
      create(:medication_group_user, user: user, medication_group: medication_group2)
    end

    it "returns medication groups associated with the user" do
      groups = user.get_user_groups
      expect(groups).to include(medication_group1, medication_group2)
    end

    it "orders groups by id desc" do
      groups = user.get_user_groups
      expect(groups.first.id).to be > groups.last.id
    end

    it "includes medication_group_users and users to avoid N+1 queries" do
      includes_values = user.get_user_groups.includes_values
      expect(includes_values).to include({ medication_group_users: :user })
    end
  end

  describe ".from_line" do
    let(:auth) do
      double(
        provider: "line",
        uid: "line123456",
        info: double(name: "LINEユーザー")
      )
    end

    context "when user does not exist" do
      it "creates a new user with LINE auth data" do
        expect {
          User.from_line(auth)
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.provider).to eq("line")
        expect(user.uid).to eq("line123456")
        expect(user.user_name).to eq("LINEユーザー")
      end
    end

    context "when user already exists" do
      let!(:existing_user) { create(:user, provider: "line", uid: "line123456") }

      it "returns the existing user" do
        expect {
          result = User.from_line(auth)
          expect(result).to eq(existing_user)
        }.not_to change(User, :count)
      end
    end
  end
end
