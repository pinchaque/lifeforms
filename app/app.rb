#!/usr/bin/env ruby

require "sinatra"
require "../app/config"

# Define route handlers below

get "/" do
  "Hello World!"  
end

get "/status" do
  # Render posts index view 
  @str = "ACTIVE"
  erb :"status"
end