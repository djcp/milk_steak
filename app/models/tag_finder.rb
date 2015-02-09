class TagFinder
  def self.by_context(context)
    ActsAsTaggableOn::Tagging.includes(:tag).where(
      taggable_type: 'Recipe',
      context: context
    ).map do |tagging|
      tagging.tag.name
    end.uniq
  end
end
