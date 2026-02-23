require 'spec_helper'

describe User do
  subject { build(:user) }

  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_presence_of :email }
  it { should validate_presence_of :username }
  it { should validate_uniqueness_of(:username).case_insensitive }
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

  context "usernames" do
    it "accepts valid usernames" do
      %w[alice alice_123 Bob_99 xyz].each do |u|
        subject.username = u
        subject.valid?
        expect(subject.errors[:username]).to be_empty
      end
    end

    it "rejects usernames with invalid characters" do
      should_not allow_value('alice bob').for(:username)
      should_not allow_value('alice!').for(:username)
    end

    it "rejects usernames shorter than 3 characters" do
      should_not allow_value('ab').for(:username)
    end

    it "rejects usernames longer than 30 characters" do
      should_not allow_value('a' * 31).for(:username)
    end
  end

  context "approval" do
    it "is active when approved" do
      user = build(:user, approved: true)
      expect(user.active_for_authentication?).to be true
    end

    it "is inactive when pending" do
      user = build(:user, :pending)
      expect(user.active_for_authentication?).to be false
    end

    it "returns :pending_approval as inactive_message when unapproved" do
      user = build(:user, :pending)
      expect(user.inactive_message).to eq :pending_approval
    end

    it "admins are always active regardless of approved flag" do
      user = build(:user, :admin, approved: false)
      expect(user.active_for_authentication?).to be true
    end
  end
end
