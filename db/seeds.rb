# Needed to use `in` mesures for Prawn
require 'prawn/measurement_extensions'

print "Rewrite templates..."

# Erase templates if exists
(1..20).each do |id|
  template = Template.where(id: id)
  if template.any?
    template[0].destroy
  end
end

# The Heritage family cover
template_1 = Template.new(
  template_type: 1,
  name: "The Heritage family cover", 
  description: "Our bestseller to date! A historic look that features a beautiful ornate border",
  position: 8
)
template_1.id = 1
template_1.save!

# The Red, White and Blue cover
template_2 = Template.new(
  template_type: 2,
  name: "The red white and blue cover", 
  description: "Bold graphic lettering in striking colors gives this cover a timeless look",
  position: 9
)
template_2.id = 2
template_2.save!

# The bistro cover
template_3 = Template.new(
  template_type: 3,
  name: "The bistro cover", 
  description: "A simple graphic design with a distinctively bistro flavor",
  position: 10
)
template_3.id = 3
template_3.save!

# Our cookbook
template_4 = Template.new(
  template_type: 4,
  name: "The tea-time cover", 
  description: "A soft feminine design with a vintage look",
  position: 11
)
template_4.id = 4
template_4.save!

# The checkered cover
template_5 = Template.new(
  template_type: 5,
  name: "The checkered cover", 
  description: "Simple and clean, like a well-starched tea towel",
  position: 12
)
template_5.id = 5
template_5.save!

# The angelic cover
template_6 = Template.new(
  template_type: 6,
  name: "The angelic cover", 
  description: "This historically inspired design features divine detailing",
  position: 13
)
template_6.id = 6
template_6.save!

# Insert Both Your Own Picture and Tagline
template_7 = Template.new(
  template_type: 7,
  name: "The semi custom cover", 
  description: "Allows you to add your own text and one large horizontal image",
  position: 2
)
template_7.id = 7
template_7.save!

# The fully customizable
template_8 = Template.new(
  template_type: 8,
  name: "The custom cover", 
  description: "Choose this design if you would like to create your own cover and divider pages",
  position: 1
)
template_8.id = 8
template_8.save!

# Chalkboard
template_9 = Template.new(
  template_type: 9,
  name: "The chalkboard cover", 
  description: "A trendy cover with the hand-drawn look of a restaurant chalkboard",
  position: 3
)
template_9.id = 9
template_9.save!

# Eat, Drink and be Merry
# All position are in inch, with origin to the bottom left
template_10 = Template.new(
  template_type: 10,
  name: "The celebrations cover", 
  description: "Pretty lettering perfect for a wedding cookbook",
  position: 4
)
template_10.id = 10
template_10.save!

# Classic
# All position are in inch, with origin to the bottom left
template_11 = Template.new(
  template_type: 11,
  name: "The classic cover", 
  description: "A versatile cover that allows you to add a large image and your own text",
  position: 5
)
template_11.id = 11
template_11.save!

# Vintage
# All position are in inch, with origin to the bottom left
template_12 = Template.new(
  template_type: 12,
  name: "The vintage cover", 
  description: "All the charm of a by-gone era bakery, perfect for any collection of sweets",
  position: 6
)
template_12.id = 12
template_12.save!

# Simple
# All position are in inch, with origin to the bottom left
template_13 = Template.new(
  template_type: 13,
  name: "The simple cover", 
  description: "Large simple letters, large prominent photo on a crisp clean background",
  position: 7
)
template_13.id = 13
template_13.save!

puts " done."

print "Rewrite plans..."


# Erase plan if exists
(1..16).each do |id|
  plan = Plan.where(id: id)
  if plan.any?
    plan[0].destroy
  end
end

# Add each plans
plan_1 = Plan.new("duration"=>1, "number_of_books"=>1, "price"=>0.0, "purchaseable"=>1, "title"=>"1 Month Free Trial Membership", "upgradeable"=>0)
plan_1.id = 1
plan_1.save!

plan_2 = Plan.new("duration"=>1, "number_of_books"=>1, "price"=>14.95, "purchaseable"=>0, "title"=>"1 Month Membership OLD", "upgradeable"=>0)
plan_2.id = 2
plan_2.save!

plan_3 = Plan.new("duration"=>5, "number_of_books"=>2, "price"=>49.95, "purchaseable"=>0, "title"=>"5 Month Membership OLD", "upgradeable"=>0)
plan_3.id = 3
plan_3.save!

plan_4 = Plan.new("duration"=>12, "number_of_books"=>3, "price"=>79.95, "purchaseable"=>0, "title"=>"1 Year Membership  - OLD", "upgradeable"=>0)
plan_4.id = 4
plan_4.save!

plan_5 = Plan.new("duration"=>0, "number_of_books"=>0, "price"=>0.0, "purchaseable"=>0, "title"=>"Contributor Only", "upgradeable"=>0)
plan_5.id = 5
plan_5.save!

plan_6 = Plan.new("duration"=>1, "number_of_books"=>3, "price"=>0.0, "purchaseable"=>0, "title"=>"Returning User + 1 Free Month Membership OLD", "upgradeable"=>0)
plan_6.id = 6
plan_6.save!

plan_7 = Plan.new("duration"=>1, "number_of_books"=>0, "price"=>14.95, "purchaseable"=>0, "title"=>"Restore Expired Cookbooks for 5 days OLD", "upgradeable"=>0)
plan_7.id = 7
plan_7.save!

plan_8 = Plan.new("duration"=>2, "number_of_books"=>1, "price"=>29.95, "purchaseable"=>0, "title"=>"2 Month Membership OLD", "upgradeable"=>0)
plan_8.id = 8
plan_8.save!

plan_9 = Plan.new("duration"=>4, "number_of_books"=>2, "price"=>39.95, "purchaseable"=>0, "title"=>"4 Month Membership OLD", "upgradeable"=>0)
plan_9.id = 9
plan_9.save!

plan_10 = Plan.new("duration"=>12, "number_of_books"=>3, "price"=>59.95, "purchaseable"=>0, "title"=>"1 Year Membership OLD", "upgradeable"=>0)
plan_10.id = 10
plan_10.save!

plan_11 = Plan.new("duration"=>1, "number_of_books"=>3, "price"=>9.95, "purchaseable"=>0, "title"=>"1 Month Membership Upgrade OLD", "upgradeable"=>0)
plan_11.id = 11
plan_11.save!

plan_12 = Plan.new("duration"=>1, "number_of_books"=>1, "price"=>29.95, "purchaseable"=>1, "title"=>"1 Month Membership", "upgradeable"=>1)
plan_12.id = 12
plan_12.save!

plan_13 = Plan.new("duration"=>2, "number_of_books"=>1, "price"=>39.95, "purchaseable"=>1, "title"=>"2 Month Membership", "upgradeable"=>1)
plan_13.id = 13
plan_13.save!

plan_14 = Plan.new("duration"=>4, "number_of_books"=>2, "price"=>49.95, "purchaseable"=>1, "title"=>"4 Month Membership", "upgradeable"=>1)
plan_14.id = 14
plan_14.save!

plan_15 = Plan.new("duration"=>12, "number_of_books"=>3, "price"=>59.95, "purchaseable"=>1, "title"=>"1 Year Membership", "upgradeable"=>1)
plan_15.id = 15
plan_15.save!

plan_16 = Plan.new("duration"=>1, "number_of_books"=>3, "price"=>19.95, "purchaseable"=>0, "title"=>"1 Month Membership Upgrade", "upgradeable"=>1)
plan_16.id = 16
plan_16.save!

puts " done."

print "Rewrite book bindings..."

# Erase book bindings if exists
(1..4).each do |id|
  binding = BookBinding.where(id: id)
  if binding.any?
    binding[0].destroy
  end
end

# Create book bindings
plastic_coil = BookBinding.new name: "Plastic Coil", max_number_of_pages: 400
plastic_coil.id = 1
plastic_coil.save!
wiro = BookBinding.new name: "Wiro", max_number_of_pages: 150
wiro.id = 2
wiro.save!
soft = BookBinding.new name: "Soft", max_number_of_pages: 400
soft.id = 3
soft.save!
hard = BookBinding.new name: "Hard", max_number_of_pages: 400
hard.id = 4
hard.save!

puts " done."