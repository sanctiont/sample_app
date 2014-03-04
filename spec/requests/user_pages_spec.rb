require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

  describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end

    
  
  

  describe "signup page" do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end


  describe "profile page" do
  	# Replace with code to make a user variable
  	let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:tweet, user: user, content: "Foo") }
    let!(:m2) { FactoryGirl.create(:tweet, user: user, content: "Bar") }

  	before { visit user_path(user) }

  	it { should have_content(user.name) }
  	it { should have_title(user.name) }
    it { should_not have_selector('div.pagination') }


    describe "tweets" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.tweets.count) }
    end
  end

#new
describe "no delete links for other's tweets" do
  let(:user) { FactoryGirl.create(:user)}
  let(:usery) { FactoryGirl.create(:user, email: "ben@m.com")}
  let!(:mx) {FactoryGirl.create(:tweet, user: user, content: "shouldn't find")}
  let!(:my)  {FactoryGirl.create(:tweet, user: usery, content: "no delete me!")}


  before do 
    sign_in user
    visit user_path(usery)
  end

  it { should have_content(usery.name) }
  it { should have_title(usery.name) }
  it { should_not have_selector('div.pagination') }
  it { should have_content(my.content)}
  it { should_not have_content(mx.content)}
  it { should_not have_link('delete')}


end


 describe "profile page w pagination" do
    # Replace with code to make a user variable
    let(:user) { FactoryGirl.create(:user) }
    

    before do
      visit user_path(user) 
    end

    before(:all) do 
        31.times { FactoryGirl.create(:tweet, user: user) } 
      end
    after(:all)  { Tweet.delete_all }


    it { should have_content(user.name) }
    it { should have_title(user.name) }
    it { should have_selector('div.pagination') }


    describe "tweets" do
      it { should have_content(user.tweets.count) }
    end
  end




  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
		
		describe "after submission" do
         before { click_button submit }

         it { should have_title('Sign up') }
       	 it { should have_content('error') }
       	 it { should have_content('blank') }
       	 it { should have_content('invalid') }
       	 it { should have_content('too short') }
      	end


    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirm Password", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Savor') }
      end
    end
   end

   describe "signup as signed in users" do
    let(:user) { FactoryGirl.create(:user) }

    before do 
     sign_in user
     visit signup_path 
    end
    it { should_not have_title('Sign up') }
   end

  describe "using a 'create' action" do
    let(:user) { FactoryGirl.create(:user) }
    
    before do
      sign_in user, no_capybara: true
      post users_path(user)
    end 
    specify { response.should redirect_to(root_path) }
  end   

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password,
        password_confirmation: user.password } }
      end
      before { 
        sign_in user, no_capybara: true
        patch user_path(user), params 
        }
      specify { expect(user.reload).not_to be_admin }
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_content('error') }
    end
  describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end
end