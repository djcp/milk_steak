require 'spec_helper'

describe User do
  it { should validate_uniqueness_of :email }
  it { should validate_presence_of :email }

  context "email addresses" do
    it "should accept valid email addresses" do
      %w|dan@example.com dan+foo@example.example.com|.each do |email|
        subject.email = email
        subject.valid?

        expect(subject.errors.full_messages).not_to include /Email/
      end
    end

    it "should reject invalid email addresses" do
      %w|example.com foo blap.foo.com|.each do |email|
        subject.email = email
        subject.valid?

        expect(subject.errors_on(:email)).to include 'is invalid'
      end

    end
  end
end