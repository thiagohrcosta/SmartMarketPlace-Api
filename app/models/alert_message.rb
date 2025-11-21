class AlertMessage < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :company, optional: true
  enum alert_type: { info: 0, warning: 1, critical: 2 }
end
