module ApplicationHelper
  def url_to_recipe(recipe)
    recipe_path(recipe) + '/' + recipe.name_for_url
  end

  def home_page_title(filter_set)
    return '' if filter_set.active_filters.empty?
    filter_set.active_filters.map do |filter|
      "#{filter.to_s.humanize} :: #{filter_set.send(filter)}"
    end.join(' ')
  end

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
