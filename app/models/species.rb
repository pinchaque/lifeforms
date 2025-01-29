class Species < Sequel::Model(:species)
  plugin :timestamps, :force => true, :update_on_create => true
end