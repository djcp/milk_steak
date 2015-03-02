module ApplicationHelper
  def markdown_format(text)
    if text.present?
      renderer = Redcarpet::Render::HTML.new(
        safe_links_only: true,
        no_styles: true,
        escape_html: true
      )
      markdown = Redcarpet::Markdown.new(
        renderer,
        autolink: true
      )
      %Q|<div class="markdown-content">#{markdown.render(text)}</div>|
    end
  end

  def featured_image_class(image)
    if image.featured?
      "featured"
    else
      "not_featured"
    end
  end
end
