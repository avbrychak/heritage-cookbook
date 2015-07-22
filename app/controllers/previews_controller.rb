class PreviewsController < ApplicationController

  # Verify if the preview is rendered
  before_filter :preview_file_ready?

  # Render HTTP code 200 if the preview file is ready.
  def status
    render nothing: true, status: :ok
  end

  # Send the preview PDF file if the preview is rendered.
  def download
    sleep 1 # Wait until the PDF engine finish writing the file
    send_file session[:preview_filename], type: "application/pdf"
    session[:preview_filename] = nil
  end

  private

  # Render HTTP code 404 if the preview file is not ready.
  def preview_file_ready?
    if !session[:preview_filename] || !File.exist?(session[:preview_filename])
      render nothing: true, status: :not_found
    end
  end
end