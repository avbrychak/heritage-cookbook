require 'rfpdf'

ActionView::Template::register_template_handler 'rfpdf', RFpdf::View