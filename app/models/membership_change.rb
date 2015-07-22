class MembershipChange < ActiveRecord::Base
  attr_accessible :plan_id, :expiry_date, :transaction_data, :express_token, :express_payer_id, 
    :number_of_books, :notes

  # -- Validations ----------------------------------------------------------
  
  validates_presence_of :user_id, :plan_id

  # -- Relationships --------------------------------------------------------
  
  belongs_to :user
  belongs_to :plan

  # -- Named Scopes ---------------------------------------------------------
  
  default_scope :order => 'created_at DESC'

end
