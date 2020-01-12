require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
  end
  #=> テストは設定によって、テストを並列で動かすことがよくある。複数のメールに関するテストが並列で動くと、.deliveries.size で調べる個数が、
  # ずれてしまうことが、稀にある。なので、.deliveries.clear で、Action mailer に溜まっているmailオブジェクトをリセットさせる。

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
  end
  
  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    
    assert_equal 1, ActionMailer::Base.deliveries.size #=> .deliveries.size は、送信待ちのmailオブジェクトの数を調べるメソッド。
    user = assigns(:user)           #=> assigns メソッドは、該当するコントローラー内（'users#create'）の、インスタンス変数を引っ張ってくる。
    assert_not user.activated?      # インスタンス変数の中身を精査したいときに使用する。
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in? #=> test/helper.rb で定義したメソッド。
    
  end
  
end
