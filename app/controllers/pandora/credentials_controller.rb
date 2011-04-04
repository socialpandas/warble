class Pandora::CredentialsController < Pandora::BaseController
  skip_before_filter :check_pandora_credentials!, :only => :update
  respond_to :json

  def update
    @user = current_user
    @user.pandora_username = params[:pandora_username]
    @user.pandora_password = params[:pandora_password]
    @user.save
    head :ok  # TODO: correct http code?
  end

  def destroy
    @user.pandora_username = nil   # TODO: move to model
    @user.pandora_password = nil
    head :ok  # TODO: correct http code?
  end
end