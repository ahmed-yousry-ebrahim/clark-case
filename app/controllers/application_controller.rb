class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include CanCan::ControllerAdditions

  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    head :unauthorized
  end
end
