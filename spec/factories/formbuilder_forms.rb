FactoryGirl.define do
  factory :form, class: Formbuilder::Form do

  end

  factory :kitchen_sink_form, parent: :form do
    after(:create) do |f|
      options = [{'checked' => 'false', 'label' => 'Choice #1'}, {'checked' => 'false', 'label' => 'Choice #2'}]

      f.response_fields.create(label: "Text", type: "Formbuilder::ResponseFieldText", sort_order: 0)
      # f.response_fields.create(label: "Paragraph", field_type: "paragraph", sort_order: 1, field_options: {"size" => 'large', "required" => true, "description" => "How would you complete this project?"})
      # f.response_fields.create(label: "Checkboxes", field_type: "checkboxes", sort_order: 2, field_options: {"options" => options, "required" => true})
      # f.response_fields.create(label: "THE SECTION!", field_type: "section_break", sort_order: 3)
      # f.response_fields.create(label: "Radio", field_type: "radio", sort_order: 4, field_options: {"options" => options, "required" => true})
      # f.response_fields.create(label: "Dropdown", field_type: "dropdown", sort_order: 5, field_options: {"options" => options, "required" => true, "include_blank_option" => true})
      # f.response_fields.create(label: "Price", field_type: "price", sort_order: 6, field_options: {"required" => true})
      # f.response_fields.create(label: "Number", field_type: "number", sort_order: 7, field_options: {"required" => true, "units" => "things"})
      # f.response_fields.create(label: "Date", field_type: "date", sort_order: 8, field_options: {"required" => true})
      # f.response_fields.create(label: "Time", field_type: "time", sort_order: 9, field_options: {"required" => true})
      # f.response_fields.create(label: "Website", field_type: "website", sort_order: 10, field_options: {"required" => true})
      # f.response_fields.create(label: "File", field_type: "file", sort_order: 11, field_options: {"required" => true})
      # f.response_fields.create(label: "Email", field_type: "email", sort_order: 12, field_options: {"required" => true})
      # f.response_fields.create(label: "Address", field_type: "address", sort_order: 13, field_options: {"required" => true})
    end
  end
end
