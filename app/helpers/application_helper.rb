module ApplicationHelper
  def featured_image_class(image)
    if image.featured?
      "featured"
    else
      "not_featured"
    end
  end
end
