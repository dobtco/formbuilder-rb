module Formbuilder
  module Views
    class Form < Erector::Widget

      needs :form,
            :entry,
            current_page: 1,
            action: '',
            method: 'POST'

      def content
        page_list if @form.multi_page?

        form_tag @action, method: @method, class: 'formbuilder-form', multipart: true do
          input type: 'hidden', name: 'page', value: @current_page
          render_fields
          actions
        end
      end

      def page_list
        ul.unstyled.inline.formbuilder_form_pages_list {
          (1..@form.num_pages).each do |x|
            if x == @current_page
              li { span x }
            else
              li.active { a x, href: url_for(params.merge(page: x)) }
            end
          end
        }
      end

      def actions
        opts = {}

        unless first_page?
          opts[:go_back_text] = "Back to page #{previous_page}"
          opts[:go_back_html] = { href: url_for(params.merge(page: previous_page)) }
        end

        if last_page?
          opts[:continue_text] = 'Submit'
        else
          opts[:continue_text] = 'Next page'
        end

        div(class: 'form-actions') {
          if opts[:go_back_text]
            a.button opts[:go_back_text], opts[:go_back_html]
          end

          button.button.primary opts[:continue_text]
        }
      end

      private
      def render_fields
        @form.response_fields_for_page(@current_page).each do |response_field|
          widget Formbuilder::Views::FormField.new(response_field: response_field, entry: @entry)
        end
      end

      def first_page?
        @current_page == 1
      end

      def previous_page
        @current_page - 1
      end

      def next_page
        @current_page + 1
      end

      def last_page?
        @current_page == @form.num_pages
      end

    end
  end
end
