Rails.application.routes.draw do

  get 'forms/:id' => 'forms#show', as: :form

end
