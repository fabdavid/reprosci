require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ReproRes
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

        # Action mailer settings.                                                                                                                                             
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              ENV['SMTP_ADDRESS'],
      port:                 ENV['SMTP_PORT'].to_i,
      #  domain:               ENV['SMTP_DOMAIN'],                                                                                                                        
      #  user_name:            ENV['SMTP_USERNAME'],                                                                                                                      
      #  password:             ENV['SMTP_PASSWORD'],                                                                                                                      
      #  authentication:       ENV['SMTP_AUTH'],                                                                                                                          
      enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO'] == 'true'
    }

   # config.action_mailer.default_url_options = {                                                                                                                         
      #   host: ENV['ACTION_MAILER_HOST']                                                                                                                                 
     # :host => "mail.epfl.ch",                                                                                                                                           
     # :port => 25                                                                                                                                                        
   # }                                                                                                                                                                    
    config.action_mailer.default_options = {
      from: ENV['ACTION_MAILER_DEFAULT_FROM']
    }

    
  end
end
