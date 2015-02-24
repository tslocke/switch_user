if SwitchUser.generate_routes
  Rails.application.routes.draw do
    get :switch_user, :to => 'switch_user#set_current_user'
  end
end
