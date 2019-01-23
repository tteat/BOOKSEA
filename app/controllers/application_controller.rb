class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_layout_options

  before_action :configure_permitted_parameters, if: :devise_controller?
  @recommendation = Book.where(id: rand(1..40)).first
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name phone])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name phone])
    @recommendation = Book.where(id: rand(1..40)).first

  end

  def set_layout_options
    @type = devise_controller? ? :devise : :application
    @recommendation = Book.where(id: rand(1..40)).first

  end
end
