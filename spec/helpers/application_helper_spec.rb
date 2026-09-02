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

  # markdown_format renders user-supplied recipe descriptions and directions, so
  # its Redcarpet flags are a security boundary, not a formatting preference.
  describe '#markdown_format' do
    it 'escapes raw HTML rather than rendering it' do
      output = helper.markdown_format('<script>alert(1)</script>')

      expect(output).not_to include('<script>')
      expect(output).to include('&lt;script&gt;')
    end

    it 'refuses to build a link for a javascript: url' do
      output = helper.markdown_format('[click me](javascript:alert(1))')

      # safe_links_only leaves the markdown un-converted rather than stripping
      # the scheme, so the payload survives as inert text. What matters is that
      # no anchor is produced for it.
      expect(output).not_to match(/<a[^>]+javascript:/)
      expect(output).not_to include('<a ')
    end

    it 'refuses to build a link for a data: url' do
      output = helper.markdown_format('[x](data:text/html;base64,PHNjcmlwdD4=)')

      expect(output).not_to include('<a ')
    end

    it 'keeps ordinary links and emphasis' do
      output = helper.markdown_format('**bold** and [a link](https://example.com)')

      expect(output).to include('<strong>bold</strong>')
      expect(output).to include('href="https://example.com"')
    end

    it 'autolinks bare urls' do
      expect(helper.markdown_format('see https://example.com')).to include('<a href="https://example.com"')
    end

    it 'returns nil for blank input' do
      expect(helper.markdown_format('')).to be_nil
      expect(helper.markdown_format(nil)).to be_nil
    end
  end

  describe '#home_page_title' do
    it 'is blank when nothing is filtered' do
      expect(helper.home_page_title(FilterSet.new({}))).to eq('')
    end

    it 'describes a single active filter' do
      expect(helper.home_page_title(FilterSet.new(name: 'cake'))).to eq('Name :: cake')
    end

    it 'joins multiple active filters' do
      title = helper.home_page_title(FilterSet.new(name: 'cake', author: 'dan'))

      expect(title).to include('Name :: cake')
      expect(title).to include('Author :: dan')
    end
  end
end
