class RemoveTemplateAttributesFromDatabases < ActiveRecord::Migration
  def up
    remove_column :templates, :has_image
    remove_column :templates, :tag_lines
    remove_column :templates, :book_color
    remove_column :templates, :book_font
    remove_column :templates, :cover_title_y
    remove_column :templates, :cover_title_font_size
    remove_column :templates, :show_book_title_on_inner_cover
    remove_column :templates, :headers_font_size
    remove_column :templates, :headers_font_style
    remove_column :templates, :toc_header_y
    remove_column :templates, :section_header_y
    remove_column :templates, :max_tag_line_1_length
    remove_column :templates, :max_tag_line_2_length
    remove_column :templates, :max_tag_line_3_length
    remove_column :templates, :max_tag_line_4_length
    remove_column :templates, :cover_user_image_y
    remove_column :templates, :cover_user_image_max_width
    remove_column :templates, :cover_user_image_max_height
    remove_column :templates, :cover_title_font_style
    remove_column :templates, :inner_cover_title_y
    remove_column :templates, :inner_cover_font_size
    remove_column :templates, :section_user_image_y
    remove_column :templates, :section_user_image_max_width
    remove_column :templates, :section_user_image_max_height
    remove_column :templates, :cover_text_padding_right
    remove_column :templates, :cover_color
    remove_column :templates, :header_color
    remove_column :templates, :inner_cover_color
  end
end
