require 'spec_helper'

describe ApplicationHelper do
  describe '#armored_email' do
    it 'renders the address reversed inside an armored span' do
      expect(helper.armored_email('chef@example.com'))
        .to eq('<span class="armored-email">moc.elpmaxe@fehc</span>')
    end

    it 'returns nil when the address is blank' do
      expect(helper.armored_email(nil)).to be_nil
      expect(helper.armored_email('')).to be_nil
    end
  end

  describe '#author_display' do
    it 'prefers the username' do
      recipe = build_stubbed(:recipe)

      expect(helper.author_display(recipe)).to eq(recipe.user_username)
    end

    it 'falls back to an armored email when the username is blank' do
      author = build_stubbed(:user, username: '')
      recipe = build_stubbed(:recipe, user: author)

      displayed = helper.author_display(recipe)

      expect(displayed).to eq(helper.armored_email(author.email))
      expect(displayed).not_to include(author.email)
    end
  end
end
