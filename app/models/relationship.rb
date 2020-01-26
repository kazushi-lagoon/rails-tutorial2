class Relationship < ApplicationRecord
  
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  # belongs_to :user =>  user_id==@user.id という形の紐づき。以下のようにしたい。
  #                      follower_id==@user.id
  # form_for の引数で、オプションを渡したときのように、レールから外れる部分は、オプションとして必要な情報を渡す。
  # belongs_to :follower だけだと、follower_id==@follower.id で、Follwerクラスを探そうとしてしまう。が、そんなクラスは存在しない。
  # そこで、オプションで、class_name: "User"　とする。これで、follower_id==@user.id となる。
  # has_many 同様、belongs_to も、メソッドを定義するメソッドである。
  # rails では、外部キーの名前を使って、どれとどれを紐づけるかを推測する。<class>_id で、<class> から紐づける対象のモデルを推測している。
  
  validates :follower_id, presence: true
  validates :followed_id, presence: true
  
end
