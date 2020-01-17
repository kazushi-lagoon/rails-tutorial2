require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum") # 慣習的に正しい書き方。
    #=> .build は、モデル同士が関連付けができていると使用可能なメソッド。user_id属性には、自動的に@user.id が入る。
    
    # 次のコードは慣習的に正しくない
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    #=> user_id は、間違えてしまうと他人を偽ることになってしまうので、開発においてもできるだけ触りたくない。
    
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
  
  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end
  
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
  
end
