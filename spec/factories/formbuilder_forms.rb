FactoryGirl.define do
  factory :form, class: Formbuilder::Form do
  end

  factory :kitchen_sink_form, parent: :form do
    after(:create) do |f|
      options = [{'checked' => 'false', 'label' => 'Choice #1'}, {'checked' => 'false', 'label' => 'Choice #2'}]

      # @todo fix these required fields to match :form_with_one_field
      f.response_fields.create(label: "Text", type: "Formbuilder::ResponseFieldText", sort_order: 0)
      f.response_fields.create(label: "Paragraph", type: "Formbuilder::ResponseFieldParagraph", sort_order: 1, field_options: {"size" => 'large', "required" => true, "description" => "How would you complete this project?"})
      f.response_fields.create(label: "Checkboxes", type: "Formbuilder::ResponseFieldCheckboxes", sort_order: 2, field_options: {"options" => options, "required" => true})
      f.response_fields.create(label: "THE SECTION!", type: "Formbuilder::ResponseFieldSectionBreak", sort_order: 3)
      f.response_fields.create(label: "Radio", type: "Formbuilder::ResponseFieldRadio", sort_order: 4, field_options: {"options" => options, "required" => true})
      f.response_fields.create(label: "Dropdown", type: "Formbuilder::ResponseFieldDropdown", sort_order: 5, field_options: {"options" => options, "required" => true, "include_blank_option" => true})
      f.response_fields.create(label: "Price", type: "Formbuilder::ResponseFieldPrice", sort_order: 6, field_options: {"required" => true})
      f.response_fields.create(label: "Number", type: "Formbuilder::ResponseFieldNumber", sort_order: 7, field_options: {"required" => true, "units" => "things"})
      f.response_fields.create(label: "Date", type: "Formbuilder::ResponseFieldDate", sort_order: 8, field_options: {"required" => true})
      f.response_fields.create(label: "Time", type: "Formbuilder::ResponseFieldTime", sort_order: 9, field_options: {"required" => true})
      f.response_fields.create(label: "Website", type: "Formbuilder::ResponseFieldWebsite", sort_order: 10, field_options: {"required" => true})
      f.response_fields.create(label: "File", type: "Formbuilder::ResponseFieldFile", sort_order: 11, field_options: {"required" => true})
      f.response_fields.create(label: "Email", type: "Formbuilder::ResponseFieldEmail", sort_order: 12, field_options: {"required" => true})
      f.response_fields.create(label: "Address", type: "Formbuilder::ResponseFieldAddress", sort_order: 13, field_options: {"required" => true})
    end
  end

  factory :form_with_one_field, parent: :form do
    after(:create) do |f|
      f.response_fields.create(label: "Text", type: "Formbuilder::ResponseFieldText", sort_order: 0, required: true)
    end
  end
end
