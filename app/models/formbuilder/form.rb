module Formbuilder
  class Form < ActiveRecord::Base

    has_many :response_fields, dependent: :destroy
    belongs_to :formable, polymorphic: true

  end
end
