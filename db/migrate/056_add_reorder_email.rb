class AddReorderEmail < ActiveRecord::Migration
  def self.up
    Textblock.create(  
      :name         => "email_reorder_receipt", 
      :description  => "Email / Re-Order Receipt",
      :text         => "Dear (=user_name=), 

Congratulations on your bestseller! 

Your reprint file has just been sent to the printer and so it wont be long now. Hume Imaging will print your cookbook in 10-15 business days and then sent it out to you via FedEx Ground. 

The following information is important - Please keep a copy of it. Print it out and keep it safely. 

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


Thanks,

Susan
      ",
      :text_html    => "<<p>Dear (=user_name=),</p>


      	<p>Congratulations on your bestseller!</p>


      	<p>Your reprint file has just been sent to the printer and so it wont be long now. Hume Imaging will print your cookbook in 10-15 business days and then sent it out to you via FedEx Ground.</p>


      	<p>The following information is important - Please keep a copy of it. Print it out and keep it safely.</p>


      	<h1>Order Receipt</h1>


      	<p>This is to confirm the information just sent to the printer.</p>


      	<h2>Order Details:</h2>


      	<p>Order Number: (=id=)<br />
      Number of Books: (=number_of_books=)<br />
      Printing Cost: (=printing_cost=)<br />
      Shipping Cost: (=shipping_cost=)<br />
      Total Charged: (=total_cost=)</p>


      	<h2>Please bill:</h2>


      	<p>(=bill_first_name=) (=bill_last_name=)<br />
      (=bill_address=)<br />
      (=bill_address2=)<br />
      (=bill_city=) (=bill_state=),<br />
      (=bill_country=) (=bill_zip=)<br />
      (=bill_phone=)<br />
      (=bill_email=)</p>


      	<h2>Please ship the books to:</h2>


      	<p>(=ship_first_name=) (=ship_last_name=)<br />
      (=ship_address=)<br />
      (=ship_address2=)<br />
      (=ship_city=) (=ship_state=)<br />
      (=ship_country=) (=ship_zip=)<br />
      (=ship_phone=)<br />
      (=ship_email=)</p>


      	<p>Thanks,</p>


      	<p>Susan</p>"
    )
  end

  def self.down
    Textblock.find_by_name('email_reorder_receipt').destroy
  end
end
