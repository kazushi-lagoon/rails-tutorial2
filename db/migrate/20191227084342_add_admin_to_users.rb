class AddAdminToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :admin, :boolean, default: false
    #=> boolean は、trueとfalse の二つが入る型のこと。しかし、実際には、この二値以外にnil が入る可能性があるので、このカラムに対する処理を実装する時、
    # nil チェックする必要が出てしまう。そのため、defaultオプションで、false を指定することで、明示的にnil を与えない限り、adminカラムは
    # trueとfalse の二値となり、nilチェックが必要なくなる。このような使われ方で、マイグレーションファイルにおいて、defaultオプションは結構頻繁に使われる。
    #=> user.toggle!(:admin) => true となり、以降にadminカラムを呼び出すと、user.admin? => true となり、最初のメソッドの処理の変更が継続され、これを
    # 破壊的メソッドと呼び、なくても正常に動作するが、分かりやすいように、!を付けることが慣習となっている。
  end
end
