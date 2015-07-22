# Copyright (c) 2006 Ed Moss <www.4ssoM.com>
#
# The MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Thanks go out to Bruce Williams of codefluency who created RTex. This 
# template handler is modification of his work.
#
# Example Registration
# 
#   ActionView::Base::register_template_handler 'rfpdf', RFpdfView

module RFpdf
  
  class View

    def initialize(action_view)
      @action_view = action_view
    end

    def render(template, local_assigns)
		  unless @action_view.controller.headers["Content-Type"] == 'application/pdf'
			  @generate = true
				@action_view.controller.headers["Content-Type"] = 'application/pdf'
			end
      assigns = @action_view.assigns.dup
    
      if content_for_layout = @action_view.instance_variable_get("@content_for_layout")
        assigns['content_for_layout'] = content_for_layout
      end

      result = @action_view.instance_eval do
			  assigns.each do |key,val|
			    instance_variable_set "@#{key}", val
		    end
			  local_assigns.each do |key,val|
		  		class << self; self; end.send(:define_method,key){ val }
				end
        ERB.new(template).result(binding)
      end
    end

  end
  
end