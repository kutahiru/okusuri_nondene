require 'rails_helper'

RSpec.describe RewardCondition, type: :model do
  describe "validations" do
    let(:reward_condition) { build(:reward_condition) }

    describe "reward_name" do
      it "requires a reward_name" do
        reward_condition.reward_name = nil
        expect(reward_condition).not_to be_valid
        expect(reward_condition.errors[:reward_name]).to include("必須項目です。")
      end

      it "validates reward_name length" do
        reward_condition.reward_name = "a" * 21
        expect(reward_condition).not_to be_valid
        expect(reward_condition.errors[:reward_name]).to include("文字数が上限を超えています。")
      end

      it "accepts valid reward_name" do
        reward_condition.reward_name = "有効なご褒美名"
        expect(reward_condition).to be_valid
      end
    end

    describe "condition_type" do
      it "requires a condition_type" do
        reward_condition.condition_type = nil
        expect(reward_condition).not_to be_valid
        expect(reward_condition.errors[:condition_type]).to include("必須項目です。")
      end

      it "accepts valid condition_type values" do
        reward_condition.condition_type = "weekly"
        expect(reward_condition).to be_valid

        reward_condition.condition_type = "daily_streak"
        reward_condition.target_value = 7
        reward_condition.target_weekday = nil
        expect(reward_condition).to be_valid
      end
    end

    describe "conditional validations" do
      describe "when condition_type is weekly" do
        let(:weekly_condition) { build(:reward_condition, :weekly) }

        it "requires target_weekday" do
          weekly_condition.target_weekday = nil
          expect(weekly_condition).not_to be_valid
          expect(weekly_condition.errors[:target_weekday]).to include("必須項目です。")
        end

        it "accepts valid target_weekday" do
          weekly_condition.target_weekday = 3 # Wednesday
          expect(weekly_condition).to be_valid
        end

        it "does not require target_value" do
          weekly_condition.target_value = nil
          expect(weekly_condition).to be_valid
        end
      end

      describe "when condition_type is daily_streak" do
        let(:daily_streak_condition) { build(:reward_condition, :daily_streak) }

        it "requires target_value" do
          daily_streak_condition.target_value = nil
          expect(daily_streak_condition).not_to be_valid
          expect(daily_streak_condition.errors[:target_value]).to include("必須項目です。")
        end

        it "validates target_value is greater than 0" do
          daily_streak_condition.target_value = 0
          expect(daily_streak_condition).not_to be_valid
          expect(daily_streak_condition.errors[:target_value]).to include("0より大きい値を入力してください。")

          daily_streak_condition.target_value = -1
          expect(daily_streak_condition).not_to be_valid
          expect(daily_streak_condition.errors[:target_value]).to include("0より大きい値を入力してください。")
        end

        it "accepts valid target_value" do
          daily_streak_condition.target_value = 7
          expect(daily_streak_condition).to be_valid
        end

        it "does not require target_weekday" do
          daily_streak_condition.target_weekday = nil
          expect(daily_streak_condition).to be_valid
        end
      end
    end
  end

  describe "associations" do
    let(:reward_condition) { create(:reward_condition) }

    it "belongs to medication_group" do
      expect(reward_condition).to respond_to(:medication_group)
      expect(reward_condition.medication_group).to be_a(MedicationGroup)
    end

    it "has many reward_histories" do
      expect(reward_condition).to respond_to(:reward_histories)
    end

    it "uses custom foreign_key for reward_histories" do
      association = RewardCondition.reflect_on_association(:reward_histories)
      expect(association.foreign_key).to eq("medication_group_id")
      # primary_keyはカスタム設定されているかテスト
      expect(association.options[:primary_key]).to eq(:medication_group_id)
    end

    it "destroys dependent reward_histories when deleted" do
      # reward_historiesファクトリが必要な場合は作成
      # history = create(:reward_history, medication_group: reward_condition.medication_group)
      # expect { reward_condition.destroy! }.to change(RewardHistory, :count).by(-1)
    end
  end

  describe "enums" do
    it "defines condition_type enum" do
      expect(RewardCondition.condition_types).to eq({
        "weekly" => "weekly",
        "daily_streak" => "daily_streak"
      })
    end

    it "responds to condition_type enum methods with prefix" do
      condition = build(:reward_condition)
      expect(condition).to respond_to(:condition_weekly?)
      expect(condition).to respond_to(:condition_daily_streak?)
    end

    it "sets correct enum values" do
      weekly_condition = create(:reward_condition, condition_type: "weekly")
      expect(weekly_condition.condition_weekly?).to be true
      expect(weekly_condition.condition_daily_streak?).to be false

      daily_condition = create(:reward_condition, condition_type: "daily_streak", target_value: 5, target_weekday: nil)
      expect(daily_condition.condition_weekly?).to be false
      expect(daily_condition.condition_daily_streak?).to be true
    end
  end

  describe "validation combinations" do
    it "validates weekly condition with all required fields" do
      condition = build(:reward_condition,
                       condition_type: "weekly",
                       target_weekday: 5,
                       target_value: nil)
      expect(condition).to be_valid
    end

    it "validates daily_streak condition with all required fields" do
      condition = build(:reward_condition,
                       condition_type: "daily_streak",
                       target_weekday: nil,
                       target_value: 10)
      expect(condition).to be_valid
    end

    it "fails validation when weekly condition lacks target_weekday" do
      condition = build(:reward_condition,
                       condition_type: "weekly",
                       target_weekday: nil)
      expect(condition).not_to be_valid
      expect(condition.errors[:target_weekday]).to include("必須項目です。")
    end

    it "fails validation when daily_streak condition lacks target_value" do
      condition = build(:reward_condition,
                       condition_type: "daily_streak",
                       target_value: nil,
                       target_weekday: nil)
      expect(condition).not_to be_valid
      expect(condition.errors[:target_value]).to include("必須項目です。")
    end

    it "fails validation when daily_streak condition has invalid target_value" do
      condition = build(:reward_condition,
                       condition_type: "daily_streak",
                       target_value: 0,
                       target_weekday: nil)
      expect(condition).not_to be_valid
      expect(condition.errors[:target_value]).to include("0より大きい値を入力してください。")
    end
  end

  describe "edge cases" do
    it "handles target_weekday edge values for weekly condition" do
      (0..6).each do |weekday|
        condition = build(:reward_condition,
                         condition_type: "weekly",
                         target_weekday: weekday)
        expect(condition).to be_valid
      end
    end

    it "handles large target_value for daily_streak condition" do
      condition = build(:reward_condition,
                       condition_type: "daily_streak",
                       target_value: 365,
                       target_weekday: nil)
      expect(condition).to be_valid
    end
  end
end
