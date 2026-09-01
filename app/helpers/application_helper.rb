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

  def armored_email(email)
    return nil if email.blank?

    content_tag(:span, email.reverse, class: 'armored-email')
  end

  def author_display(recipe)
    recipe.user_username.presence || armored_email(recipe.user_email)
  end
end
