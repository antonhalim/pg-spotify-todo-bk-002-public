require 'bundler/setup'
require 'base64'
require 'json'
require 'open-uri'
require 'pry'

Bundler.require

require_relative 'sql_runner'
require_relative '../lib/data_loader'