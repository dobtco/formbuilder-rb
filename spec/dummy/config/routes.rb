Rails.application.routes.draw do

  controller :test, scope: :test do
    get 'forms/:id', action: :show_form, as: :form
    post 'forms/:id', action: :post_form
  end

end
