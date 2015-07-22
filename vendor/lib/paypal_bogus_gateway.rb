require 'active_merchant/billing/gateways/paypal/paypal_common_api'
require 'active_merchant/billing/gateways/paypal/paypal_express_response'
require 'active_merchant/billing/gateways/paypal_express_common'

# Active Merchant `BogusGateway` does not support `PaypalExpressGateway`.
# This patch create a `PaypalBogusGateway` class supporting `PaypalExpressGateway` missing methods.
# See: https://github.com/Shopify/active_merchant/pull/424.
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class PaypalBogusGateway < BogusGateway

      REDIRECT_URL = "https://bogus.paypal.com"

      def setup_authorization money, options = {}
        requires!(options, :return_url, :cancel_return_url)
       
        PaypalExpressResponse.new true, SUCCESS_MESSAGE, { Token: AUTHORIZATION }, test: true
      end

      def setup_purchase money, options = {}
        requires!(options, :return_url, :cancel_return_url)
       
        PaypalExpressResponse.new true, SUCCESS_MESSAGE, { Token: AUTHORIZATION }, test: true
      end

      def authorize money, options = {}
        requires!(options, :token, :payer_id)
        
        case normalize(options[:token])
        when '1'
          PaypalExpressResponse.new false, FAILURE_MESSAGE, {:authorized_amount => money}, :test => true
        else
          PaypalExpressResponse.new true, SUCCESS_MESSAGE, {:authorized_amount => money}, :test => true, :authorization => AUTHORIZATION
        end
      end

      def purchase money, options = {}
        requires!(options, :token, :payer_id)
        
        case normalize(options[:token])
        when '1'
          PaypalExpressResponse.new false, FAILURE_MESSAGE, {:amount => money}, :test => true
        else
          PaypalExpressResponse.new true, SUCCESS_MESSAGE, {:amount => money}, :test => true, :authorization => AUTHORIZATION
        end
      end

      def details_for token
        "Testing"
      end
      
      def redirect_url_for token, options={}
        REDIRECT_URL
      end

    end
  end
end
