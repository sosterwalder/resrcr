namespace :db do
  desc 'This task drops, creates, migrates and (re-)seeds the current database. It then changes the owner for the "development.sqlite3" file to the user www-data and the group www-data. It modifies the rights of the file to 777 and then restarts apache 2 webserver.'
  task :rebuild_database do
    system("cd #{Rails.root}")
    system("rake db:drop")
    system("rake db:create")
    system("rake db:migrate")
    system("rake db:seed")
    system("chown www-data:www-data db/development.sqlite3")
    system("chmod 777 db/development.sqlite3")  
    system("service apache2 restart")
  end
end
