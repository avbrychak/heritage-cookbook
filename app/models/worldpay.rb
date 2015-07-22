class Worldpay
  URL = 'https://select.worldpay.com/wcc/purchase?'
  
   attr_accessor  :instId,
                  :testMode,
                  :currency,
                  :fixContact, #If present, this causes contact details to be displayed in non-editable format.
                  :desc,
                  :cartId,
                  :amount,
                  :M_upgrade_plan,
                  :MC_transaction_type,
                  :name,
                  :address,
                  :postcode,
                  :country,
                  :tel,
                  :email
  
  def initialize(args = {})
    self.instId         = WORLDPAY_INSTALLATION_ID
    self.testMode       = WORLDPAY_MODE
    self.currency       = 'USD'
    self.fixContact     = true
    
    self.desc           = args[:desc] || 'Heritage Cookbooks Membership Fee'
    self.cartId         = args[:cartId] || ''
    self.amount         = args[:amount] || 0
    self.M_upgrade_plan = args[:M_upgrade_plan] || ''
    self.MC_transaction_type    = args[:MC_transaction_type] || ''
    self.name           = args[:name] || ''
    self.address        = args[:address] || ''
    self.postcode       = args[:postcode] || ''
    self.country        = args[:country] || ''
    self.tel            = args[:tel] || ''
    self.email          = args[:email] || ''
  end
  
  def url
    worldpay_params = []
    [:instId,
     :testMode,
     :currency,
     :fixContact,
     :desc,
     :cartId,
     :amount,
     :M_upgrade_plan,
     :MC_transaction_type,
     :name,
     :address,
     :postcode,
     :country,
     :tel,
     :email].each do |attr|
      worldpay_params << ["#{attr}=#{CGI.escape(self.send(attr).to_s)}"]
    end
    return URL+worldpay_params.join('&')    
  end
end