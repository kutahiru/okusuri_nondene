require 'rails_helper'

RSpec.describe MedicationGroupInvitation, type: :model do
  describe "associations" do
    let(:invitation) { create(:medication_group_invitation) }

    it "belongs to medication_group" do
      expect(invitation).to respond_to(:medication_group)
      expect(invitation.medication_group).to be_a(MedicationGroup)
    end

    it "belongs to user" do
      expect(invitation).to respond_to(:user)
      expect(invitation.user).to be_a(User)
    end
  end

  describe "#accept_invitation!" do
    let(:invitation) { create(:medication_group_invitation) }
    let(:invited_user) { create(:user) }

    context "when invitation is accepted successfully" do
      it "adds user to the medication group" do
        expect {
          invitation.accept_invitation!(invited_user.id, "family_watcher")
        }.to change(MedicationGroupUser, :count).by(1)

        group_user = MedicationGroupUser.last
        expect(group_user.user).to eq(invited_user)
        expect(group_user.medication_group).to eq(invitation.medication_group)
        expect(group_user.user_type).to eq("family_watcher")
      end

      it "increments used_count" do
        expect {
          invitation.accept_invitation!(invited_user.id, "family_watcher")
        }.to change { invitation.reload.used_count }.by(1)
      end

      it "returns the created MedicationGroupUser" do
        result = invitation.accept_invitation!(invited_user.id, "medication_taker")
        expect(result).to be_a(MedicationGroupUser)
        expect(result.user).to eq(invited_user)
        expect(result.medication_group).to eq(invitation.medication_group)
      end

      it "handles medication_taker type correctly" do
        result = invitation.accept_invitation!(invited_user.id, "medication_taker")
        expect(result.user_type).to eq("medication_taker")
      end
    end

    context "when transaction fails" do
      before do
        allow(MedicationGroupUser).to receive(:add_user_to_group!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "rolls back the transaction" do
        original_count = invitation.used_count

        expect {
          invitation.accept_invitation!(invited_user.id, "family_watcher")
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect(invitation.reload.used_count).to eq(original_count)
        expect(MedicationGroupUser.where(user: invited_user, medication_group: invitation.medication_group)).to be_empty
      end
    end

    context "when user validation fails" do
      let(:invitation) { create(:medication_group_invitation) }

      before do
        # グループの最大ユーザー数に達している状況をシミュレート
        create(:medication_group_user, medication_group: invitation.medication_group, user_type: "medication_taker")
        3.times { create(:medication_group_user, :family_watcher, medication_group: invitation.medication_group) }
      end

      it "raises validation error and rolls back transaction" do
        original_count = invitation.used_count

        expect {
          invitation.accept_invitation!(invited_user.id, "family_watcher")
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect(invitation.reload.used_count).to eq(original_count)
      end
    end
  end

  describe ".find_by_token" do
    let(:invitation) { create(:medication_group_invitation) }

    context "with valid token" do
      it "returns the invitation" do
        token = invitation.signed_id(purpose: :medication_group_invitation)
        result = MedicationGroupInvitation.find_by_token(token)
        expect(result).to eq(invitation)
      end
    end

    context "with invalid token" do
      it "returns nil for invalid token" do
        result = begin
          MedicationGroupInvitation.find_by_token("invalid_token")
        rescue => e
          nil
        end
        expect(result).to be_nil
      end
    end

    context "with expired token" do
      it "returns nil for expired token" do
        token = nil
        travel_to(1.week.ago) do
          token = invitation.signed_id(purpose: :medication_group_invitation, expires_in: 1.day)
        end

        travel_to(1.week.from_now) do
          result = begin
            MedicationGroupInvitation.find_by_token(token)
          rescue => e
            nil
          end
          expect(result).to be_nil
        end
      end
    end

    context "with wrong purpose token" do
      it "returns nil for wrong purpose token" do
        token = invitation.signed_id(purpose: :other_purpose)
        result = begin
          MedicationGroupInvitation.find_by_token(token)
        rescue => e
          nil
        end
        expect(result).to be_nil
      end
    end
  end

  describe ".find_or_create_active_invitation" do
    let(:group) { create(:medication_group) }
    let(:user) { create(:user) }

    context "when no active invitation exists" do
      it "creates a new invitation" do
        expect {
          MedicationGroupInvitation.find_or_create_active_invitation(group.id, user.id)
        }.to change(MedicationGroupInvitation, :count).by(1)

        invitation = MedicationGroupInvitation.last
        expect(invitation.medication_group).to eq(group)
        expect(invitation.user).to eq(user)
        expect(invitation.max_uses).to eq(3)
        expect(invitation.used_count).to eq(0)
        expect(invitation.expires_at).to be_within(1.minute).of(3.days.from_now)
      end
    end

    context "when active invitation already exists" do
      let!(:existing_invitation) do
        create(:medication_group_invitation,
               medication_group: group,
               user: user,
               expires_at: 2.days.from_now,
               used_count: 1)
      end

      it "returns the existing invitation" do
        expect {
          result = MedicationGroupInvitation.find_or_create_active_invitation(group.id, user.id)
          expect(result).to eq(existing_invitation)
        }.not_to change(MedicationGroupInvitation, :count)
      end
    end

    context "when invitation exists but is expired" do
      let!(:expired_invitation) do
        create(:medication_group_invitation, :expired,
               medication_group: group,
               user: user)
      end

      it "creates a new invitation" do
        expect {
          MedicationGroupInvitation.find_or_create_active_invitation(group.id, user.id)
        }.to change(MedicationGroupInvitation, :count).by(1)

        new_invitation = MedicationGroupInvitation.last
        expect(new_invitation).not_to eq(expired_invitation)
        expect(new_invitation.expires_at).to be > Time.current
      end
    end

    context "when invitation exists but max uses reached" do
      let!(:max_used_invitation) do
        create(:medication_group_invitation, :max_used,
               medication_group: group,
               user: user,
               expires_at: 2.days.from_now)
      end

      it "creates a new invitation" do
        expect {
          MedicationGroupInvitation.find_or_create_active_invitation(group.id, user.id)
        }.to change(MedicationGroupInvitation, :count).by(1)

        new_invitation = MedicationGroupInvitation.last
        expect(new_invitation).not_to eq(max_used_invitation)
        expect(new_invitation.used_count).to eq(0)
      end
    end

    context "when multiple conditions apply" do
      let!(:expired_invitation) do
        create(:medication_group_invitation, :expired,
               medication_group: group,
               user: user)
      end
      let!(:max_used_invitation) do
        create(:medication_group_invitation, :max_used,
               medication_group: group,
               user: user,
               expires_at: 2.days.from_now)
      end
      let!(:active_invitation) do
        create(:medication_group_invitation, :partially_used,
               medication_group: group,
               user: user,
               expires_at: 2.days.from_now)
      end

      it "returns the active invitation" do
        expect {
          result = MedicationGroupInvitation.find_or_create_active_invitation(group.id, user.id)
          expect(result).to eq(active_invitation)
        }.not_to change(MedicationGroupInvitation, :count)
      end
    end

    context "edge cases" do
      it "handles exactly at expiration time" do
        freeze_time do
          create(:medication_group_invitation,
                 medication_group: group,
                 user: user,
                 expires_at: Time.current) # 正確に現在時刻

          expect {
            MedicationGroupInvitation.find_or_create_active_invitation(group.id, user.id)
          }.to change(MedicationGroupInvitation, :count).by(1)
        end
      end

      it "handles exactly at max uses" do
        create(:medication_group_invitation,
               medication_group: group,
               user: user,
               used_count: 3,
               max_uses: 3,
               expires_at: 2.days.from_now)

        expect {
          MedicationGroupInvitation.find_or_create_active_invitation(group.id, user.id)
        }.to change(MedicationGroupInvitation, :count).by(1)
      end
    end
  end
end
