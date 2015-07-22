// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery.ui.sortable
//= require jquery.ui.widget
//= require jquery.ui.datepicker
//= require jquery_ujs
//= require jquery.leanModal.min
//= require jquery.atooltip.min
//= require jquery.scrollintoview.min
//= require jquery.iframe-transport
//= require jquery.fileupload
//= require load-image.min
//= require jquery.heritageAutoSaveForm
//= require_tree .

// Render a rails template (same as `remote: true` in links or form)
var render = function(url){
  $.ajax({url: url, dataType: "script"})
}

// Enable Modals
var enableModals = function(){
  $('.modal-link').leanModal({top : 0, closeButton: ".close-modal"}); 
}

// Enable Previews Links
var enablePreviewLinks = function(){
  $('.preview-link').click(function(e){
    var url = $(this).data('preview-url');
    render(url);
  });
}

$(document).ready(function(){
  enableModals();
  enablePreviewLinks();
});