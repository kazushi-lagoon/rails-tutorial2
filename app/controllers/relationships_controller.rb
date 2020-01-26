class RelationshipsController < ApplicationController
  before_action :logged_in_user
  # before_action :correct_user,   only: [:create, :destroy]  は、必要ない。攻撃者が、他人と他人の関係性を作ることを防ぎたいわけだが、
  # それぞれのアクション内を見て分かる通り、current_user.follow(user) のように、ログインしている人と誰かの関係性を変えるだけなので、
  # ある人とある人との関係性を第三者が変える、ということは、このbeforeフィルターがなくても始めからできない。

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
