class PasswordResetsController < ApplicationController
  
  before_action :get_user,   only: [:edit, :update]
  #=> editアクション、updateアクションの、両方で、@user = User.find_by(email: params[:email])　がある。
  # beforeフィルターを用いた、リファクタリング。しかし、コードを読む側が、あちこち見なければいけない範囲が広がるので、議論の余地がある。
  # ただし、:get_user がないと、:valid_user　でも、@user = User.find_by(email: params[:email])　を書く必要がでてしまう。なので、
  # :get_user　は、イメージとしては、beforebefore フィルターで、:valid_user　ので、前に呼び出す。
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  
  def new
  end
  
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end
  
  # PATCH '/password_resets/:id'
  # submit ボタンを押すと、'password_resets/:id/edit' の:id が、'/password_resets/:id' の:id に入る。
  def update
    if params[:user][:password].empty?                  
      @user.errors.add(:password, :blank)
      #=> user.rb で、passwordカラムが、allow_nilオプションによって、空でもパスワードをリセットできてしまう。なので、自分で上記のようなコードで、
      # これを解決する。.errors.add によって、エラー文を持たせることができる。実は、user.rb のバリデーションを走らせるときにも、
      # 裏側で、.errors.add が動いているだけなので、自分で用意しても同じことができる。
      
      render 'edit'
    elsif @user.update_attributes(user_params)          
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'                                     
    end
  end
  
  private
  
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end
    
    # トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
  
end
