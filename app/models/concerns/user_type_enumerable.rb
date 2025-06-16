module UserTypeEnumerable
  extend ActiveSupport::Concern

  included do
    enum user_type: {
      medication_taker: 0,
      family_watcher: 1
    }
  end
end
