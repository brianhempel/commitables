Rails.application.routes.draw do
  resources :tables, only: [:index, :show, :new, :create] do
    resources :columns, only: [:new, :create, :edit, :update, :destroy]
    resources :rows,    only: [:new, :create, :edit, :update, :destroy]
  end

  root to: redirect("/tables")
end
