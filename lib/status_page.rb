require 'rest-client'
require 'status_page/request'
require 'status_page/component'

module StatusPage

  def set_component_status(name, status_type)
    component = Component.find_matching_name(name) || raise("No component matching '#{name}'")
    component.update_status status_type
  end
  module_function :set_component_status

end
