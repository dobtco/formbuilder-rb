Formbuilder
========

## The `Form` model
```ruby
#  formable_id   :integer
#  formable_type :string(255)

class Form < ActiveRecord::Base

  include Formbuilder::Form

end
```

## The `Entry` model
```ruby
#  responses       :hstore
#  responses_text  :text

class Entry < ActiveRecord::Base

  include Formbuilder::Entry

end
```

## The `ResponseField` model
```ruby
#  label         :text
#  type          :string(255)
#  field_options :text
#  sort_order    :integer
#  required      :boolean          default(FALSE)
#  blind         :boolean          default(FALSE)
#  admin_only    :boolean          default(FALSE)

class ResponseField < ActiveRecord::Base

  include Formbuilder::ResponseFields::Base

end
```

#### License

MIT