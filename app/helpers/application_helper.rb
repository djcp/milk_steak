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

  # Built once: Redcarpet's renderer and parser are stateless after
  # configuration, and this ran twice per recipe show. The flags are a security
  # boundary (see spec/helpers/application_helper_spec.rb), not formatting
  # preference -- escape_html and safe_links_only are what keep user-supplied
  # recipe text inert.
  MARKDOWN = Redcarpet::Markdown.new(
    Redcarpet::Render::HTML.new(safe_links_only: true, no_styles: true, escape_html: true),
    autolink: true
  ).freeze

  def markdown_format(text)
    return if text.blank?

    %(<div class="markdown-content">#{MARKDOWN.render(text)}</div>)
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
