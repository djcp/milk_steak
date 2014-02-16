shared_examples 'an object tagged in the context of' do |tag_context|
  context tag_context do
    context_method = "#{tag_context.singularize}_list".to_sym

    it "accepts a comma-delimited string and turns it into an array of #{tag_context}" do
      recipe = build(:recipe, context_method => 'foo, bar, baz, blee')

      expect(recipe.send(context_method)).to eq ['foo','bar','baz','blee']
    end

    it "has lowercased #{tag_context} automatically" do
      recipe = build(:recipe, context_method => 'FOO')

      expect(recipe.send(context_method)).to eq ['foo']
    end

    it "cleans up unused #{tag_context} after deletion" do
      recipe = create(:recipe, context_method => 'foo')
      recipe.send(context_method).remove('foo')
      recipe.save

      expect(ActsAsTaggableOn::Tag.find_by_name('foo')).not_to be
    end
  end
end
