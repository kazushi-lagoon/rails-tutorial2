class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  #=> 仮想的属性を与える。仮想的属性の生存期間は、次のリクエストが発行されるまで。コンソール上では、exit するまで。
  # 仮想的属性は、一時的にオブジェクトに値を持たせるが、データベースには反映させない情報。今回は、この情報が消失するまでに、ユーザーのクッキーに
  # 保存し、ハッシュ化させた値をデータベースに保存したい。
  # password の時は、has_secure_password で自動的に実装されたが、今回は自分で実装する必要がある。
  # 実体は、以下の二つのメソッドの実装。セッターとゲッターという。
  # def remember_token=(token)
  #   @remember = token
  # end
  # def remember_token
  #   @remember
  # end
  
  before_save   :downcase_email
  #=> beforeフィルターのモデルバージョンで、コールバック処理という。
  # また、before_save {self.email = email.downcase} とすることもできる。メソッドはそもそもコードの塊なので、ブロックで渡すことも可能である。
  # :downcase_emailで呼び出す方法を、メソッド参照といい、メソッドを呼び出すときは、: がつく。
  # 基本的にはないが、メールアドレスの大文字・小文字を区別してくれないDBがあるかもしれないので、念のために、小文字にしておく。
  before_create :create_activation_digest
  # before_create は、新しくカラムが作成されて、保存されるときにだけ、実行されるが、before_save は、それに加えて、既存のカラムが更新されて、保存
  # されるときにも実行される。
  
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }  # =>オプション引数の中のオプション引数。
                    # uniquenessのデフォルトでは、大文字・小文字を区別してしまう。
  # 通常、アドレスは大文字・小文字を区別せずに送信されるので、case_sensitive: false　で、大文字・小文字を区別せずに一意性を持たせる。
  
  has_secure_password
  # 保護すべき情報はbcryptなどのハッシュ関数を使って、不可逆的にハッシュ化させた値をデータベースに保存する。こうすることで、データベース
  # をクラックされても、元の値は分からない。このアプローチはrailsに限らない。
  # 　セキュアなパスワードの実装は、railsのメソッドであるhas_secure_passwordを使えば、簡単に完了してしまう。
  #  「セキュアに実装する」というのは、すごく難しいことなのだが（csrf対策、データベースにはハッシュ化された値を保存するなど、セキュリティの勉強が必要）、
  # そのレールがhas_secure_passwordですでに用意されている。
  #  ただし、このメソッドを使うために、こちらが用意する必要のあるものがあって、それがusersに対するpassword_digestカラムの追加と、
  # bcryptというgemのインストールである。
  # 　usersテーブルにnameカラムが存在すると、u.name="kazushi" u.save　で、nameカラムに保存できるが、has_secure_passwordでは、passwordカラムが
  # 存在しないのに、u.password="pass" ができて、u.saveとすると、password_digestカラムにbcryptでハッシュ化された値が保存される。
  
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  #=> allow_nilオプションによって、ユーザー情報の更新時に、わざわざまたパスワードを入力することを強制する、という状態を解決している。
                    
  # ActiveRecordの継承によって、saveやcreateなどのメソッドが使えるようになったのに加えて、validatesメソッドも使えるようになった。
  # このメソッドに対して、オプション引数（link_toメソッドで出た概念）を投げている形なので、presence:...,length:...　という形で、後ろからバンバンバンバン
  # 投げていく。validatesはいろいろなオプションが初めから用意されているパッケージ製品のようなもので、使いたいものを（今回でいうところの、presenceやlength
  # など）オプション引数として、投げていく。
  
  # 渡された文字列のハッシュ値を返す
  def User.digest(string) #=> 書く場所は、helperでもcontrollerでも問題ないが、ユーザーに関するものなので、ここに書いた。
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost) #=> BCryptのドキュメントから、与えられた引数をハッシュ化させるコード。また、costオプションでは、
                                                # 本来はハッシュ化させることにはコストがかかるが、テストにおけるパスワードは漏洩しても特に問題ない
                                                # ので、本番ではちゃんとハッシュ化させて、テストでは簡易的にハッシュ化させるということをさせている。
                                                # ?は三項演算子というもの。
  end
  # def digest(string)ではなく、def User.digest(string) なのは、インスタンスメソッドではなく、クラスメソッドだから。インスタンスメソッドは、
  #インスタンスに対してしか使えないので、わざわざインスタンスを生成しなくても使用できるメソッドは、全てクラスメソッドにする。クラスメソッドに
  #してしまうと、呼び出す時にわざわざインスタンスを生成しなくてはならなくなる。
  # ダブルコロン（::）は、rubyの世界における、ディレクトリの階層の区分け（/）のようなものとして捉えるとよい。
  
  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
    #=> 標準gemで、デフォルトで用意されているモジュール（SecureRandom）とメソッド（urlsafe_base64）で、セキュアでランダムな文字列を生成する時によく使う。
    # 「トークン」とは、パスワードと同様に秘密情報であるが、パスワードはユーザーが管理する情報であるのに対し、トークンはコンピューターが管理する情報
    # である。トークンはコンピューター同士がやりとりするものなので、無作為なものでよい。
  end
  
  def remember #=> remember me のチェックボックスをチェックした時に、呼び出されるメソッド。
    self.remember_token = User.new_token #=> self を省略してしまうと、remember_token がローカル変数として評価されてしまうので、省略不可。
                                         # update_attribute は、メソッドなので、省略可能。helper メソッドとは異なり、ここに書かれているのは全て
                                         # インスタンスメソッドなので、self. はわざわざ書かなくてもあることが自明。
    self.update_attribute(:remember_digest, User.digest(remember_token))
    # update_attribute は、バリデーションをスキップさせてデータベースに保存するメソッド。ユーザーさんが何を入力するか分からない
    # から、バリデーションをかける必要があった。今回のように、自分で発行したものを、自分で保存するケースでは、その必要がない。
  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    self.update_attribute(:remember_digest, nil)
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  # def authenticated?(remember_token)
  #   return false if remember_digest.nil? #=> 二つの異なる種類のブラウザ（ここではChromeとFirefoxとする）で、同時にこのアプリを立ち上げ、
                                         # Chromeでログアウトしてから、一度Firefoxのブラウザを落として、もう一度Firefoxでこのアプリにアクセスすると、
                                         # Chromeのログアウトによってremember_digest がnil になっていて、Firefoxでアクセスした時に、Firefoxでcookie
                                         # は残っているので、このauthenticated?メソッドが発動されて、remember_digest がnil のためBCrypt で例外エラー
                                         # が起きてしまう。BCrypt の処理では、remember_digest のところにnil が入ると、nil やfalse を返してくれるの
                                         # ではなく、エラーを発生させてしまうのである。なので、この行の処理で、このケースのとき、false を返して
                                         # 処理を止まらせる。return false if は便利な処理で、if文に該当する場合は、false という結果で終わらせて、
                                         # 以降の処理は実行させない、ということができる。この種類のバグは、cookie が残っていたら、remember_digestも
                                         # あるはずだという、誤った考えから生まれる。上でみてきたように、cookie が残っているのに、remember_digestが
                                         # 消失している場合もあり得る。
  #   BCrypt::Password.new(self.remember_digest).is_password?(remember_token)
  # end
  
  # def authenticated?(activation_token)
  #   return false if remember_digest.nil? 
  #   BCrypt::Password.new(self.activation_digest).is_password?(activation_token)
  # end
  #=> このように、activation_token の認証メソッドを新たに作成してもよいが、remember_token の認証メソッドと、コードがほとんど変わらない。
  # remember_digest と、activation_digest で、対象のカラムが変わるだけ。

  
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  #=> user=User.first で、a="foobar" で、b="reverse" にして、a.reverse=> "raboof" a.send b => "raboof" で、結果は同じになる。
  # send メソッドは、引数に文字列でメソッド名を受け取って、その処理を実行する。a.remember_digest=> nil   a.activation_digest=> bgprgq03g4pirh^039gp3b
  # のようになるが、これを抽象化して、 a="remember"のとき、  user.#{a}_digest=>nil   a="activation"のとき、user.#{a}_digest=> bgprgq03g4pirh^039gp3b
  # のようにして、#{a}_digest このメソッドに一本化したい。しかし、式展開は文字列の中でしか使用できないという問題がある。そこで、send メソッドを利用
  # して、呼び出すメソッドを文字列にして、これを解決する。user.send("#{a}_digest")
  # send メソッドを利用して、どのメソッド（カラム名）になるか、呼び出される時に（引数次第で）切り替わる、この手法を、メタプログラミングの一種で、
  # 動的ディスパッチと呼ぶ。
  # attribute=:remember にしても、ruby のルールで、シンボルも文字列の式展開では文字列になる。メソッド参照のような感じで、呼び出し元の引数のところに、
  # :rememberのように、シンボルを渡して、メソッドのために使っているというニュアンスを出すと、第三者の開発者からしても読みやすい。
  # bcrypt を使用した認証メソッドは、この一つのメソッドで事足りる。しかし、マイグレーションファイルを作成する段階から、カラム名を、
  # _digest で統一するなど、実際にこの動的ディスパッチで実装するのは、結構難易度が高い。

  # アカウントを有効にする
  def activate
    self.update_attribute(:activated,    true)
    self.update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  #=> @user.send_activation_email で、self のところに、@user が入り、もとのリファクタリングする前のコードになる。
  # クラスメソッドは、インスタンスに対しても呼び出せる。


   private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = email.downcase # 左辺は、self. がないと、変数になってしまうので注意。
    end
    
    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
  
end
