require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }

  it { should respond_to(:authenticate) }
  it { should respond_to(:tweets) }
  it { should respond_to(:feed) }

  it { should respond_to(:admin) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
   end

   describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

describe "when password is not present" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end


describe "tweet associations" do

    before { @user.save }
    let!(:older_tweet) do 
      FactoryGirl.create(:tweet, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_tweet) do
      FactoryGirl.create(:tweet, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right tweets in the right order" do
      @user.tweets.should == [newer_tweet, older_tweet]
    end

    it "should destroy associated tweets" do
      expect { @user.destroy }.to change(Tweet, :count).by(-2)
      #tweets = @user.tweets.dup
      #tweets.count.should be 2
      #@user.destroy
      #tweets.count.should be 2
      #tweets.should_not be_empty
      #tweets.each do |tweet|
       # Tweet.find_by_id(tweet.id).should be_nil
      #end
    end
    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:tweet, user: FactoryGirl.create(:user))
      end

      its(:feed) { should include(newer_tweet) }
      its(:feed) { should include(older_tweet) }
      its(:feed) { should_not include(unfollowed_post) }
    end
  end
end
