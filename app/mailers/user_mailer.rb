class UserMailer < ApplicationMailer


  def account_activation(user) #=> アカウント有効化の機能を作る上で利用するこのメールに必要な情報は、メールを送るための、ユーザーさんのemailと、
                               # メールの文面に乗せるリンクに含ませる、activation_token である。その情報を利用できるようにするためには、このメソッドに、
                               # 登録されたユーザーオブジェクトを引数として渡してもらうようにする必要がある。
    @user = user #=> メールの文面に乗せるリンクに含ませる、activation_token は、@user.activation_token で、
                 # view で使いたいので、インスタンス変数に格上げする必要がある。
    mail to: user.email, subject: "Account activation"
  end
  #=> mail to とすると、mailオブジェクトが戻り値として返ってきて、そのmailオブジェクトを使って、送信したり保存したり、いろいろなことをする。
  # Actionメイラーは、controller のクラスを継承しているので、メールの文面はViewに書くし、インスタンス変数は該当するViewで使える。
  # controller の部分をMailer といい、View の部分をMail と呼ぶ。
  #=>app/views/user_mailer/account_activation.text.erb
  #=>app/views/user_mailer/account_activation.html.erb　
  # メールを読み込む際、ブラウザのプロトコルで、textとhtml で、ブラウザが対応している方を読み込むようになっている。最近はほとんどが、html対応（Gmailなど）
  # だが、全てではないので、text も用意している。
  # 上記の二つのテンプレートが、mailオブジェクトに引数として渡される、呼び出された側に渡される。account_activation(user) は、controller っぽいが、
  # 呼び出した側で戻り値を受け取るので、メソッド（mailメソッド）として理解した方がよい。ただし、上記の二つのテンプレートがそれぞれレンダリング
  # されるところが、普通のメソッドとは異なる。
  
  
  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
