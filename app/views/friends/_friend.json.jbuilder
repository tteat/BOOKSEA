json.extract! book, :id, :first_name, :birthday, :is_male, :description, :category_id, :user_id, :created_at, :updated_at
json.url book_url(book, format: :json)
