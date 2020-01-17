class CreateMicroposts < ActiveRecord::Migration[5.1]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, foreign_key: true
      #=> foreign_key: true は、なくても問題なく紐づけができる。しかし、マイグレーションは、rails の機能ではあるが、DBに情報を伝達するスクリプトである。
      # 明示的にこれを記述することによって、DB 側で最適化が行われるかもしれない（DB による）。

      t.timestamps
    end
    
    add_index :microposts, [:user_id, :created_at]
    #=> 辞書の中の索引ページのようなスペースを、DB内に用意して、[] 内のカラムからデータを取得するとき、それを高速化している。
    # :created_at も、:user_id と同様にこの対象となってるのは、、micropost を、降順に取得して表示するためである。
    # 全てのカラムに対して、この高速化を行っても特に問題ないが、後からでもその実装はできるので、必要になったときに実装すればよい。
    # 一応、高速化すると、その分のデータをDB内で消費してしまうという、小さなデメリットは、あることにはある。
  end
end
