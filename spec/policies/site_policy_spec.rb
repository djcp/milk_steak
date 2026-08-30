require 'spec_helper'

describe SitePolicy do
  let(:guest) { nil }
  let(:user)  { build_stubbed(:user) }
  let(:admin) { build_stubbed(:user, :admin) }

  it 'lets only admins into the admin area' do
    expect(described_class.new(admin, :site).admin_area?).to be true
    expect(described_class.new(user, :site).admin_area?).to be false
    expect(described_class.new(guest, :site).admin_area?).to be false
  end

  it 'lets only admins into the magic importer' do
    expect(described_class.new(admin, :site).magic?).to be true
    expect(described_class.new(user, :site).magic?).to be false
    expect(described_class.new(guest, :site).magic?).to be false
  end
end
