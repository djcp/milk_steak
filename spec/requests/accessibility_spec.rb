require 'spec_helper'

# Guards the WCAG failures found in the 2026-08-31 audit. These assert on parsed
# markup rather than raw strings so a class rename can't silently pass.
describe 'Accessibility', type: :request do
  def page
    Nokogiri::HTML(response.body)
  end

  describe 'landmarks and bypass blocks' do
    it 'gives the public layout a main landmark reachable by a skip link' do
      get root_path

      skip_link = page.at_css('a[href="#main_content"]')
      expect(skip_link).to be_present, 'expected a skip-to-content link'
      expect(skip_link.text).to match(/skip to main content/i)

      main = page.at_css('main#main_content')
      expect(main).to be_present, 'expected <main id="main_content">'
      # Needs a tabindex to accept focus when the skip link targets it.
      expect(main['tabindex']).to eq('-1')
    end

    it 'labels each nav landmark so they can be told apart' do
      get root_path

      page.css('nav').each do |nav|
        expect(nav['aria-label']).to be_present,
                                     "every <nav> needs an aria-label; found one without: #{nav['class']}"
      end
    end
  end

  describe 'status messages' do
    it 'announces flash messages' do
      # A guest redirect carries no flash, so use the pending-approval path,
      # which does. (Warden's set_user bypasses active_for_authentication?,
      # letting the controller's own gate be the thing under test.)
      sign_in create(:user, :pending)
      get new_recipe_path
      follow_redirect!

      flash_message = page.at_css('#flash div[role]')
      expect(flash_message).to be_present, 'expected the flash to carry a role'
      expect(flash_message['role']).to be_in(%w[status alert])
      expect(flash_message['aria-live']).to be_in(%w[polite assertive])
    end
  end

  describe 'images' do
    it 'gives every image an alt attribute' do
      recipe = create(:recipe, status: 'published')
      create(:image, recipe: recipe, featured: true, caption: 'A finished cake')

      get recipe_path(recipe)

      # alt="" is correct for decorative images, so presence of the attribute
      # is what matters here, not that it is non-empty.
      page.css('img').each do |img|
        expect(img['alt']).not_to be_nil, "image #{img['src']} has no alt attribute"
      end
    end

    it 'uses the caption as the hero image alt text' do
      recipe = create(:recipe, status: 'published')
      create(:image, recipe: recipe, featured: true, caption: 'A finished cake')

      get recipe_path(recipe)

      expect(page.at_css('.hero-image img')['alt']).to eq('A finished cake')
    end

    it 'keeps the redundant card image link out of the accessibility tree' do
      recipe = create(:recipe, status: 'published')
      create(:image, recipe: recipe, featured: true)

      get root_path

      # The <h2> already links to the recipe by name; the image link duplicates
      # it, so it stays clickable but is hidden from AT and the tab order.
      card_image_link = page.at_css('.thumbnail a')
      expect(card_image_link['aria-hidden']).to eq('true')
      expect(card_image_link['tabindex']).to eq('-1')
    end
  end

  describe 'controls' do
    it 'renders the filter remove control as a named button' do
      create(:recipe, status: 'published', name: 'Cake')

      get root_path, params: { filter_set: { name: 'Cake' } }

      control = page.at_css('.remove_filter')
      expect(control.name).to eq('button'), 'remove filter must be a real button'
      expect(control['type']).to eq('button')
      expect(control['aria-label']).to match(/remove name filter/i)
    end

    it 'exposes the magic recipe source toggle state' do
      sign_in create(:user, :admin)

      get new_admin_magic_recipe_path

      pressed = page.css('.source-toggle-btn').pluck('aria-pressed')
      expect(pressed).to eq(%w[true false])
    end
  end

  describe 'form hints' do
    it 'associates each hint with its input via aria-describedby' do
      get new_user_registration_path

      input = page.at_css('#user_username')
      hint_id = input['aria-describedby']

      expect(hint_id).to be_present, 'username input is not described by its hint'
      expect(page.at_css("##{hint_id}")).to be_present,
                                            "aria-describedby points at ##{hint_id}, which does not exist"
      expect(page.at_css("##{hint_id}").text).to match(/letters, numbers/i)
    end
  end

  describe 'tables' do
    it 'scopes admin table headers to their column' do
      sign_in create(:user, :admin)
      create(:recipe)

      get admin_recipes_path

      headers = page.css('table thead th')
      expect(headers).to be_any
      expect(headers.pluck('scope').uniq).to eq(['col'])
    end
  end
end
