Formbuilder.rb [![circle ci status](https://circleci.com/gh/dobtco/formbuilder-rb.png?circle-token=a769ad2fc81271bc1869b5e5a95053efa36b376f)](https://circleci.com/gh/dobtco/formbuilder-rb) <a href='https://coveralls.io/r/dobtco/formbuilder-rb'><img src='https://coveralls.io/repos/dobtco/formbuilder-rb/badge.png' alt='Coverage Status' /></a>
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
