rm -rf solr/pids
bundle exec rake sunspot:solr:start 2>&1 > log/sunspot.log
#puma -C config/puma.rb
if [ "$RAILS_ENV" = "production" ]; then
RAILS_ENV=production bin/rails assets:precompile
fi
bundle exec unicorn -c config/unicorn.rb -E $RAILS_ENV -p 3000
