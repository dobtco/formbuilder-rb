module SubmittingAnEntrySpecHelper
  def field_name(field_type)
    "response_fields[#{form.response_fields.where(type: "Formbuilder::ResponseField#{field_type.capitalize}").first.id}]"
  end

  def escaped_field_name(field_type)
    "response_fields\[#{form.response_fields.where(type: "Formbuilder::ResponseField#{field_type.capitalize}").first.id}\]"
  end

  def save_draft_and_refresh
    click_button 'Submit'
  end

  def only_use_response_field(project, field_type)
    form.response_fields.where("field_type != ?", field_type).destroy_all
  end

  def set_field(field_type, value)
    case field_type
    when :checkboxes
      value.each_with_index do |v, i|
        send(v ? :check : :uncheck, "#{field_name(field_type)}[#{i}]")
      end
    when :radio
      choose(value) # @todo this could fail if there are multiple radio buttons on the page
    when :dropdown
      select(value, from: field_name(field_type))
    when :price
      fill_in "#{field_name(field_type)}[dollars]", with: value[:dollars]
      fill_in "#{field_name(field_type)}[cents]", with: value[:cents]
    when :date
      fill_in "#{field_name(field_type)}[month]", with: value[:month]
      fill_in "#{field_name(field_type)}[day]", with: value[:day]
      fill_in "#{field_name(field_type)}[year]", with: value[:year]
    when :time
      fill_in "#{field_name(field_type)}[hours]", with: value[:hours]
      fill_in "#{field_name(field_type)}[minutes]", with: value[:minutes]
      fill_in "#{field_name(field_type)}[seconds]", with: value[:seconds]
      select(value[:am_pm], from: "#{field_name(field_type)}[am_pm]")
    when :file
      page.execute_script %Q{ $('input[type=file]').insertAfter('.fileupload') } rescue nil
      page.attach_file "#{field_name(field_type)}[]", File.expand_path(value, File.dirname(__FILE__))
    when :address
      fill_in "#{field_name(field_type)}[street]", with: value[:street]
      fill_in "#{field_name(field_type)}[city]", with: value[:city]
      fill_in "#{field_name(field_type)}[state]", with: value[:state]
      fill_in "#{field_name(field_type)}[zipcode]", with: value[:zipcode]
      select(value[:country], from: "#{field_name(field_type)}[country]")
    when :table
      value.each_with_index do |values, i|
        all("input").select { |input| input['name']["#{field_name(field_type)}[#{i}]"] }.each_with_index do |input, index|
          input.set values[index]
        end
      end
    else
      fill_in field_name(field_type), with: value
    end
  end

  def test_field_values
    {
      text: 'Yooo',
      paragraph: 'Booo',
      checkboxes: [true, false],
      radio: 'Choice #2',
      dropdown: 'Choice #1',
      price: { dollars: '10', cents: '11' },
      number: '102',
      date: { month: '1', day: '12', year: '2013' },
      time: { hours: '1', minutes: '12', seconds: '00', am_pm: 'PM' },
      website: 'www.google.com',
      email: 'strongbad@homestarrunner.com',
      file: '../fixtures/test_files/text.txt',
      address: { street: '123 Main St.', city: 'Oakland', state: 'California', zipcode: '94609', country: 'United Kingdom' },
      table: [['yes', 'no'], ['', 'foo']]
    }
  end

  def normalized_test_field_values
    test_field_values.merge(
      website: 'http://www.google.com'
    )
  end

  def test_field_values_two
    {
      text: 'shlooop',
      paragraph: 'floooop',
      checkboxes: [false, true],
      radio: 'Choice #1',
      dropdown: 'Choice #2',
      price: { dollars: '2', cents: '14' },
      number: '32',
      date: { month: '2', day: '1', year: '2012' },
      time: { hours: '12', minutes: '1', seconds: '30', am_pm: 'AM' },
      website: 'www.gizoogle.com',
      email: 'homestar@homestarrunner.com',
      file: '../fixtures/test_files/text2.txt',
      address: { street: '125 Main St.', city: 'Berkeley', state: 'California', zipcode: '94704', country: 'Algeria' },
      table: [['no', ''], ['yes', '']]
    }
  end

  def normalized_test_field_values_two
    test_field_values_two.merge(
      website: 'http://www.gizoogle.com'
    )
  end

  def ensure_field(field_type, value)
    case field_type
    when :checkboxes
      value.each_with_index do |v, i|
        page.should(send(v ? :have_checked_field : :have_unchecked_field, "#{field_name(field_type)}[#{i}]"))
      end
    when :radio
      find("[name=\"#{escaped_field_name(field_type)}\"][value=\"#{value}\"]")['checked'].should == 'checked'
    when :dropdown
      page.should have_select(field_name(field_type), selected: value)
    when :price
      page.should have_field("#{field_name(field_type)}[dollars]", with: value[:dollars])
      page.should have_field("#{field_name(field_type)}[cents]", with: value[:cents])
    when :date
      page.should have_field("#{field_name(field_type)}[month]", with: value[:month])
      page.should have_field("#{field_name(field_type)}[day]", with: value[:day])
      page.should have_field("#{field_name(field_type)}[year]", with: value[:year])
    when :time
      page.should have_field("#{field_name(field_type)}[hours]", with: value[:hours])
      page.should have_field("#{field_name(field_type)}[minutes]", with: value[:minutes])
      page.should have_field("#{field_name(field_type)}[seconds]", with: value[:seconds])
      page.should have_select("#{field_name(field_type)}[am_pm]", selected: value[:am_pm])
    when :file
      page.should have_selector('.existing-filename', text: value.split('/').last)
    when :address
      page.should have_field("#{field_name(field_type)}[street]", with: value[:street])
      page.should have_field("#{field_name(field_type)}[city]", with: value[:city])
      page.should have_field("#{field_name(field_type)}[state]", with: value[:state])
      page.should have_field("#{field_name(field_type)}[zipcode]", with: value[:zipcode])
      page.should have_select("#{field_name(field_type)}[country]", selected: value[:country])
    when :table
      value.each_with_index do |values, i|
        all("input").select { |input| input['name']["#{field_name(field_type)}[#{i}]"] }.each_with_index do |input, index|
          input.value.should == values[index]
        end
      end
    else
      page.should have_field(field_name(field_type), with: value)
    end
  end
end