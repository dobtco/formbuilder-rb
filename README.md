Formbuilder
========

## Set up your models
#### The `ResponseField`,  `EntryAttachment`, and `Form` models live inside the engine

1. `rake formbuilder:install:migrations`
2. `rake db:migrate`

#### The `Entry` model gets mixed in to an existing model in your application
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

## Save an entry
```ruby
@entry = Entry.new(form: @form)
@entry.save_responses(params[:response_fields], @form.response_fields.not_admin_only)
```

## Validate an entry
```ruby
@entry.valid?
# => false

@entry.error_for(form.response_fields.first)
# => "can't be blank"
```

#### License

MIT
