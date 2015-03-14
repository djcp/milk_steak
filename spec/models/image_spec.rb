require 'spec_helper'

describe Image do
  it { should belong_to(:recipe) }
  it { should validate_length_of(:caption).is_at_most(1.kilobyte) }
  it { should validate_attachment_presence(:image) }

  it { should have_attached_file(:image) }

  it { should validate_attachment_content_type(:image).
                allowing('image/png', 'image/gif', 'image/jpeg').
                rejecting('text/plain', 'text/xml') }
end
