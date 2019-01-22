json.extract! activity, :id, :title, :created_at, :ended_at,:place, :content, :user_id, :created_at
json.url activity_url(activity, format: :json)
