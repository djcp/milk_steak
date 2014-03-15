require 'spec_helper'

describe Image do
  it { should validate_presence_of(:filepicker_url) }
  it { should ensure_length_of(:filepicker_url).is_at_most(255) }
  it { should belong_to(:recipe) }
  it { should ensure_length_of(:caption).is_at_most(1.kilobyte) }
end
