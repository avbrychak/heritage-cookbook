# Load `PaypalBogusGateway` to test Paypal payments.
if Rails.env.test?
  require Rails.root.join('vendor', 'lib', 'paypal_bogus_gateway.rb')
end