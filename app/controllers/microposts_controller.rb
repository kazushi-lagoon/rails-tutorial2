class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      #=> この行がないと、micropost の投稿が、バリデーションで失敗したとき、'/shared/_feed.html.erb' の、<% if @feed_items.any? %> の、
      # @feed_items が、nil でエラーする。render なので、@feed_items  が宣言できていないからである。
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy #=> @micropost は、beforeフィルター内で定義済み。
    flash[:success] = "Micropost deleted"
    redirect_to request.referrer || root_url
    #=> request.referrer このメソッドは、一つ前のURLを返す。|| root_url で、もし、見つからなければ（テストでは見つからない）、root_url へ
    # リダイレクトさせる。DELETE '/microposts/:id' は、トップページから行われるパターンと、プロフィールページから行われるパターンがあるので、削除を行った
    # あと、そのそれぞれの元いたページへリダイレクトされる。
  end
  
  private

    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end
    
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id]) #=> DELETE '/microposts/:id' から、params[:id]
      redirect_to root_url if @micropost.nil?
      #=> 今ログインしている人（自分）の、投稿の集合の中に、今消そうとしているmicropost のid と一致してるものはあるか、という検証の仕方。
    end
  
end
