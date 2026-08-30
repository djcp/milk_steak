require 'spec_helper'

describe UserPolicy do
  let(:guest) { nil }
  let(:user)  { build_stubbed(:user) }
  let(:admin) { build_stubbed(:user, :admin) }
  let(:target) { build_stubbed(:user) }

  it 'lets only admins list users' do
    expect(described_class.new(admin, target).index?).to be true
    expect(described_class.new(user, target).index?).to be false
    expect(described_class.new(guest, target).index?).to be false
  end

  it 'lets only admins approve users' do
    expect(described_class.new(admin, target).approve?).to be true
    expect(described_class.new(user, target).approve?).to be false
    expect(described_class.new(guest, target).approve?).to be false
  end
end
