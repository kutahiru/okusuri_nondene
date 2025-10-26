class WebPushNotificationService
  # ボタン付きの服薬通知
  def self.send_medication_reminder(user, medication_management_id, group_name, schedule_title)
    message = {
      title: "おくすり飲んでね",
      body: "#{group_name}\n#{schedule_title}",
      tag: "medication_reminder_#{medication_management_id}",
      url: "/",
      actions: [
        {
          action: "taken",
          title: "✅おくすり飲んだよ",
          data: { medication_management_id: medication_management_id }
        },
        {
          action: "view",
          title: "アプリを開く"
        }
      ],
      medication_management_id: medication_management_id
    }

    send_to_user(user, message)
  end

  # 見守り家族に未服薬を通知
  def self.send_family_watcher_delay_notification(user, group_name, schedule_title)
    message = {
      title: "おくすり飲んでね",
      body: "#{group_name}\n#{schedule_title}\nまだおくすり飲めてないよ",
      tag: "family_watcher_delay",
      url: "/",
      actions: [
        {
          action: "view",
          title: "アプリを確認"
        }
      ]
    }

    send_to_user(user, message)
  end

  # 見守り家族に服薬済を通知
  def self.send_family_watcher_taken_notification(user, group_name, schedule_title)
    message = {
      title: "おくすり飲んでね",
      body: "#{group_name}\n#{schedule_title}\n✅おくすり飲んだよ",
      tag: "family_watcher_taken",
      url: "/",
      actions: [
        {
          action: "view",
          title: "アプリを確認"
        }
      ]
    }

    send_to_user(user, message)
  end

  # 服薬者にご褒美を通知
  def self.send_medication_taker_reward_notification(user, group_name, reward_name)
    message = {
      title: "おくすり飲んでね",
      body: "#{group_name}\n#{reward_name}\n🎉ご褒美達成🎉",
      tag: "reward_notification",
      url: "/",
      actions: [
        {
          action: "view",
          title: "アプリを確認"
        }
      ]
    }

    send_to_user(user, message)
  end

  # 見守り家族にご褒美を通知
  def self.send_family_watcher_reward_notification(user, group_name, reward_name)
    message = {
      title: "おくすり飲んでね",
      body: "#{group_name}\n#{reward_name}\n🎉ご褒美達成🎉\nご褒美あげてね",
      tag: "reward_notification",
      url: "/",
      actions: [
        {
          action: "view",
          title: "アプリを確認"
        }
      ]
    }

    send_to_user(user, message)
  end

  private

  # 指定したユーザーの全ての有効な購読に通知を送信
  def self.send_to_user(user, message)
    user.push_subscriptions.active.each do |subscription|
      subscription.send_notification(message)
    end
  end
end
