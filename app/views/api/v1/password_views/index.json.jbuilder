json.(password_views, :total_pages, :total_entries, :previous_page, :current_page, :next_page, :per_page)

json.password_views(password_views) do |password_view|
  json.status password_view.status
  json.created_at password_view.created_at
  json.ip password_view.ip

  if password_view.viewer.present?
    json.user_email password_view.viewer.email
  end
end
