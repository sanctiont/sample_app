require 'spec_helper'

describe Tweet do
  let(:user) { FactoryGirl.create(:user) }
  before { @tweet = user.tweets.build(content: "Lorem ipsum") } 
  

  subject { @tweet }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should == user }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @tweet.user_id = nil }
    it { should_not be_valid }
  end

  describe "accessible attributes" do
    #this needs to be moved to the controller. somehow...
    it "should not allow access to user_id" do
      expect do
        Tweet.new(user_id: user.id)
      #end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
      end.to raise_error()

    end    
  end

  describe "with blank content" do
    before { @tweet.content = " " }
    it { should_not be_valid }
  end

  describe "with content that is too long" do
    before { @tweet.content = "a" * 140 }
    it { should_not be_valid }
  end
end