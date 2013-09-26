# A sample Guardfile
# More info at https://github.com/guard/guard#readme

group :all_specs do
  guard :rspec do

    watch('spec/spec_helper.rb')                        { "spec" }

    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/(.*)(\.erb|\.haml|\.slim)$})          { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    watch(%r{^app/models/formbuilder/(.+)\.rb$})        { |m| "app/models/formbuilder/#{m[1]}_spec.rb" }
    watch(%r{^lib/formbuilder/(.+)\.rb$})               { |m| "spec/lib/formbuilder/#{m[1]}_spec.rb" }

  end
end
