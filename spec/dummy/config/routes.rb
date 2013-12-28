Rails.application.routes.draw do

  resources :forms, only: [:update]

  controller :test, scope: :test do
    get 'forms/:form_id/:entry_id', action: :show_form, as: :test_form
    post 'forms/:form_id/:entry_id', action: :post_form

    get 'forms/:form_id/:entry_id/render', action: :render_entry, as: :render_entry
  end

end
