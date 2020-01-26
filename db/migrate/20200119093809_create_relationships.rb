class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id #=> この二行は、高速化のためのインデックス。
    add_index :relationships, [:follower_id, :followed_id], unique: true
    #=> これは、一意性のためのインデックス。email のときと同様、刹那のタイミングで、異なるブラウザから同時に操作が行われると、
    # バリデーションをかいくぐってしまうので、DB側にも、一意性の情報を持たせる。
    # email のときと異なり、今回は、組み合わせにおける一意性。「AさんがBさんを二回フォローする」、というようなことは、あってはならない。
    # ツイッターでこのようなことで、フォロワーを水増しさせると、サービス全体の信頼性を落とす。
    
  end
end
