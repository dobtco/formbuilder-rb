module Formbuilder
  module Form
    extend ActiveSupport::Concern

    included do
      has_many :response_fields, dependent: :destroy
      belongs_to :formable, polymorphic: true
    end

  end
end