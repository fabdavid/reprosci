rm -rf solr/pids
bundle exec rake sunspot:solr:start 2>&1 > log/sunspot.log
#puma -C config/puma.rb
bundle exec unicorn -c config/unicorn.rb -E $RAILS_ENV -p 3000
