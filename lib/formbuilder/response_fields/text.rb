class Formbuilder::ResponseFields::Text < Formbuilder::ResponseFields::Base

  include ActionView::Helpers::TagHelper

  def render_input(value, opts = {})
    tag(:input, type: 'text', name: "response_fields[#{self.id}]", class: "rf-size-#{self[:field_options]['size']}",
        data: self.length_validations, value: value)
  end

end