class Add404PageNotFoundToComatose < ActiveRecord::Migration
  def self.up
    execute("
      INSERT INTO comatose_pages (
        parent_id, 
        full_path, 
        title, 
        slug, 
        body, 
        filter_type,
        position, 
        updated_on, 
        created_on
      ) VALUES (
        1,
        '404',
        'Page not found',
        '404',
        '<h1>Page Not Found</h1><p>The page you were looking for does not exist on this system. Please try again.</p>',
        '[No Filter]',
        0,
        '#{Time.now.to_s(:db)}',
        '#{Time.now.to_s(:db)}'
      )
    ")
  rescue
    self.down
    raise
  end

  def self.down
    execute("DELETE comatose_pages WHERE slug='404'")
  end
end
