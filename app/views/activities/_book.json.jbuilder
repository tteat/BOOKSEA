json.extract! activity, :id, :title, :ended_at, :content, :user_id, :created_at
json.url activity_url(activity, format: :json)
