json.array!(@contacts) do |contact|
  json.extract! contact, :id, :name, :address, :city, :phone, :email
  json.url contact_url(contact, format: :json)
end
