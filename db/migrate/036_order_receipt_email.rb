class OrderReceiptEmail < ActiveRecord::Migration
	def self.up
		Textblock.create (
			:name => 'email_order_receipt',
			:description => 'Email / Order Receipt',
			:text => 'Dear (=user_name=),
			
Congratulations! You have done it – you have created your cookbook!

Your file has just been sent to the printer and so it won’t be long now. Hume Imaging will print your cookbook in 10-15 business days and then sent it out to you via FedEx.

The following information is important – Please keep a copy of it. Print it out and keep it safely.

h1. Order Receipt

This is to confirm the information just sent to the printer.

h2. Order Details:

Order Number: (=id=)<br />
Number of Books: (=number_of_books=)<br />
Printing Cost: (=printing_cost=)<br />
Shipping Cost: (=shipping_cost=)<br />
Total Charged: (=total_cost=)

h2. Please bill:

(=bill_first_name=) (=bill_last_name=)<br />
(=bill_address=)<br />
(=bill_address2=)<br />
(=bill_city=) (=bill_state=),<br />
(=bill_country=) (=bill_zip=)<br />
(=bill_phone=)<br />
(=bill_email=)

h2. Please ship the books to:

(=ship_first_name=) (=ship_last_name=)<br />
(=ship_address=)<br />
(=ship_address2=)<br />
(=ship_city=) (=ship_state=)<br />
(=ship_country=) (=ship_zip=)<br />
(=ship_phone=)<br />
(=ship_email=)

h2. Special Instructions:

(=notes=)


h1. Reordering More Cookbooks

# If your membership is still active – you reorder your cookbooks through the website, just the way you placed this first order.

# If your membership has expired, call the printer, Bobby at Hume Imaging (1-800-296-6813 ext 233) and tell him how many books you wish to order. You will need to be able to refer to the file name above and the date of this file transfer so that the printer can find your file.


Please email me and tell me what you think about the books when they arrive. 

I hope that they are a wonderful success and I look forward to helping you with the next volume.
',
			:text_html => ''
		)
	end

	def self.down
		t = Textblock.find_by_name 'email_order_receipt'
		t.destroy
	end
end
