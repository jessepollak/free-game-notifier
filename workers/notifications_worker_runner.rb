require 'iron_worker'
require 'yaml'
require 'active_support/core_ext'

load 'notifications_worker.rb'

config_data = YAML.load_file('config.yml')

IronWorker.configure do |config|
  config.token = config_data['token']
  config.project_id = config_data['project_id']
end

worker = NotificationsWorker.new
worker.mongo_port = config_data['mongo']['port']
worker.mongo_host = config_data['mongo']['host']
worker.mongo_db_name = config_data['mongo']['db_name']
worker.mongo_user = config_data['mongo']['user']
worker.mongo_password = config_data['mongo']['password']

#worker.schedule fill this out