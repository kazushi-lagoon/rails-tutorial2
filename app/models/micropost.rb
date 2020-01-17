class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  #=> default_scopeは、データを取得するとき、どのような順番で取得するかを指定するメソッド。
  # a= -> { puts "foo" } として、a.call => "foo"  Procオブジェクトは、.call で呼び出せる。
  # ブロックとはコードの塊で、それを変数に代入したり、メソッドとして定義したりして、持ち運び可能にするものが、Procクラス、Procオブジェクトである。
  # 'application.html.erb'の、<%= yield %> は、入れ子構造になっているわけだが、これはコードの塊をProcオブジェクトとして持ち運び可能にして、
  # 場合に応じてそれぞれ渡して展開する、ということを行って、実現可能にしている。
  # ここで、Procオブジェクトを利用しているのは、データを取得する、その瞬間に指定の方法で（今回は、created_at: :desc）ソートしたいから。
  # 一旦呼び出してその時の最新順ではダメで、毎回毎回それぞれ呼び出した瞬間の最新順でなければ困る。
  # default_scope の引数として、Procオブジェクトを渡している。
  
  mount_uploader :picture, PictureUploader
  
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  
  validate  :picture_size
  
  private

    # アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
  
  
end
