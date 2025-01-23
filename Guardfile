guard 'rack', port: 9292, host: "127.0.0.1" do
  watch('Gemfile.lock')
  watch(%r{^(config|app|public)/.*})
end