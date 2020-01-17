require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper
  #=> full_titleメソッドを使いたいから。テストは、Helper のデフォルトのスコープの範囲外なので、include で明示的にコーディングする。

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    #=> get user_path(@user) で、返ってきたHTMLが、response.body に格納されているので、それを呼び出している。注意点は、bodyタグではなく、
    # headタグなども含めた、HTML全体である。assert_match は、assert_select と異なり、どのHTMLタグを探すのかを伝える必要がない。
    # response.body　のどこかしらにあれば、そこを探し出して、テストする。
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end