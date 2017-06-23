class SwitchUserController < ApplicationController
  before_filter :developer_modes_only

  def set_current_user
    handle_request(params)
    
    to = SwitchUser.redirect_path.call(request, params)
    if to == :back
      redirect_back(fallback_location: root_path)
    else
      redirect_to(to)
    end
  end

  private

  def developer_modes_only
    render :text => "Permission Denied", :status => 403 unless available?
  end

  def available?
    SwitchUser.guard_class.new(self, provider).controller_available?
  end

  def handle_request(params)
    if SwitchUser.switch_back
      provider.remember_current_user(params[:remember] == "true")
    end

    if params[:scope_identifier].blank?
      provider.logout_all
    else
      record = SwitchUser.data_sources.find_scope_id(params[:scope_identifier])
      unless record
        provider.logout_all
        return
      end
      if SwitchUser.login_exclusive
        provider.login_exclusive(record.user, :scope => record.scope)
      else
        provider.login_inclusive(record.user, :scope => record.scope)
      end
    end
  end

  # TODO make helper methods, so this can be eliminated from the
  # SwitchUserHelper
  def provider
    SwitchUser::Provider.init(self)
  end
end
