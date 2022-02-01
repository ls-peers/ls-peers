# ls-peers

## Running locally
### With Bundle
1) Clone repo
2) `$ cd` into repo
3) Run `$ bundle install`
4) Run `$ bundle exec ruby peers.rb`

### With Heroku
1) Clone repo
2) `$ cd` into repo
3) Run `$ bundle install`
3) Run `$ heroku local`

## Deploying to production
### With Github
1) Merge branch with main (Heroku auto deploys changes to main)

### With Heroku
1) Run `$ git push heroku [branch-name]`

## Updating database
### Locally
1) `$ psql lspeers`
2) `lspeers=# \i [path to .sql]`

### Heroku
1) `$ heroku pg:psql -a lspeers`
2) `lspeers::DATABASE=> \i [path to .sql]`

### Scripts for full DB reload
1) `\i ./delete_test_data.sql`
2) `\i ./schema.sql`
3) `\i ./load_join_tables.sql`
4) `\i ./test_data.sql`
