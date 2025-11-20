class AlertMessage < ApplicationRecord
  belongs_to :product
  enum alert_type: { info: 0, warning: 1, critical: 2 }
end
