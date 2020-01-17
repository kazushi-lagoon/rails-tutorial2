class StaticPagesController < ApplicationController
  def home
    # app/views/リソース名/アクション名.html.erb
    # app/views/static_pages/home.html.erb
    # @micropost = current_user.microposts.build if logged_in?
    
    if logged_in?
      @micropost  = current_user.microposts.build
        #=> .build は、モデル同士が関連付けができていると使用可能なメソッド。user_id属性には、自動的に@user.id が入る。
        # usersコントローラーの、newアクション内で、@user=User.new として、空のオブジェクトであるが、型情報として、
        # form_for の引数に渡してラクに実装、という方法と同じである。
    
        # 次のコードは慣習的に正しくない
        # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
        #=> user_id は、間違えてしまうと他人を偽ることになってしまうので、開発においてもできるだけ触りたくない。
      
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
    
  end

  def help
  end
  
  def about
  end
  
  def contact
  end
end
