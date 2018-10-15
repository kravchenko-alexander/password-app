if passwords.count == 1
  json.password passwords.first
else
  json.password_set(passwords) do |password|
    json.password password
  end
end
