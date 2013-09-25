Formbuilder
========

## Set up your models


#### The `Entry` model
```ruby
#  submitted_at    :datetime
#  responses       :hstore
#  responses_text  :text

class Entry < ActiveRecord::Base

  include Formbuilder::Entry

end
```


## Render a form
```erb
<%= Formbuilder::FormRenderer.new(@form, @entry).to_html %>
```

#### License

MIT