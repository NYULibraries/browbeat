require 'figs'; Figs.load
require 'rest-client'
require 'status_page/request'
require 'status_page/component'

module StatusPage

  def set_component_status(id, status_type)
    component = Component.find(id) || raise("No component with ID '#{id}'")
    component.update_status status_type
  end
  module_function :set_component_status

end
