require 'spec_helper'

describe User do
  it { should validate_uniqueness_of :email }
  it { should validate_presence_of :email }
  it { should have_many(:recipes) }

  context "email addresses" do
    it "should accept valid email addresses" do
      %w|dan@example.com dan+foo@example.example.com|.each do |email|
        subject.email = email
        subject.valid?

        expect(subject.errors.full_messages).not_to include /Email/
      end
    end

    %w|example.com foo blap.foo.com|.each do |email|
      it "should reject invalid email addresses" do
        should_not allow_value(email).for(:email)
      end

    end
  end
end
