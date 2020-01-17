class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  # helper　メソッドの元々の使い方は、。gravatar_forやfull_titleがそうだったように、viewで使うもの。デフォルトでview で使える。
  # controller　で使う場合は、include で読み込んで、使えるスコープを広げる必要がある。
  
  def hello
    render html: "hello, world!"
  end
  
  
  private
  #=> privateメソッドは、外側のクラスでは呼び出せないが、継承した子クラスでは呼び出せる。
  
   # ログイン済みユーザーかどうか確認
   def logged_in_user #=> このメソッドも、このコントローラー内でしか使わないので、privateメソッドにした。
      unless logged_in? #=> unless は、if not を意味する。
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
   end
    #=> ログインしていない状態で、edit,update が呼び出されるケースは、直接リクエストを送る場合が考えられる。しかし他に、edit の呼び出しに関しては、
    # ブラウザのヘッダーのSettingはログイン状態でなければ存在しないが、元々ログインしていたのに、たまたまsessionやcookie が切れてしまっていて、
    # ログインしていないのに、Setting　が表示されているケース起こり得る。
  
end
