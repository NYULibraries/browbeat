module Browbeat
  module SuccessHelper
    SUCCESS_TEXT_CONFIG_FILEPATH = 'config/success_text.yml' unless defined?(SUCCESS_TEXT_CONFIG_FILEPATH)

    # returns URL for given case-insensitive name as defined in YAML config file
    def success_text_for(app_name)
      app_name.downcase!
      success_text_hash[app_name] || raise("Success text for \"#{app_name}\" is not defined. Define it in #{SUCCESS_TEXT_CONFIG_FILEPATH}")
    end

    private
    def success_text_hash
      @@url_hash ||= read_success_text_hash
    end

    def read_success_text_hash
      YAML.load File.open(SUCCESS_TEXT_CONFIG_FILEPATH){|f| f.read}
    end
  end

end
