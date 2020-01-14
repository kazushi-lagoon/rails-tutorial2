# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first #=> preview で、テストするためのものなので、使用するユーザーオブジェクトは、テキトーでよい。
    user.activation_token = User.new_token
    UserMailer.account_activation(user) #=> メールクラス内で定義したメソッドなので、mailオブジェクトが返ってくる。
                                        # 特殊なクラス内（UserMailer）で定義したメソッドで、この場合は、クラスメソッドに変換される。
  end
  #=> 上記のコメントアウトされたURLに、ドメイン名だけ書き換えたものでGETリクエストを送ると、戻り値として受け取ったmail オブジェクトで、
  # どのようなメールが送られるのかプレビューできる。これが、Action mailer preview の仕組み。
  # 今回はAction mailer previewを利用して、生成した、'.../account_activations/:id/edit' が正しく貼り付けられているかを確認したい。
  # delivery_method = :test のログは、開発環境で、実際にユーザー登録してメールが送られるとき、そのメールの内容が確認できるというもの。
  # preview では、実際にメールが送られていない状態で、どのようなメールの内容になるかを確認できる。

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    user.reset_token = User.new_token
    UserMailer.password_reset(user)
  end

end
