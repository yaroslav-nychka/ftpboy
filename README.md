Setup

1. Prepare FTP servers for testing

``$ docker-compose up``
``$ sftp ituity@localhost -P 7777``
``$ sftp itervent@localhost -P 8888``

2. Run tests

``$ rspec``

3. Run worker

``$ bundle exec sidekiq -r ./lib/worker.rb``

4. Run sidekiq Web UI

``$ rackup``
