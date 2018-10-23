Sidekiq worker for transferring files between 2 FTP servers

QUICK START:

 - Install & run docker:
``https://www.docker.com/get-started``

 - Run tests
    -  ``$ docker-compose -f docker-compose.test.yml``
    -  ``$ rspec``
    
 - Run worker
 ``$ docker-compose -f docker-compose.local.yml up``
 
 - Open Sidekiq UI to see processed and failed jobs
 ``$ rackup``

HOW IT WORKS:
 
1. Run two FTP servers in docker containers
``$ docker-compose -f docker-compose.test.yml``

2. Create test file for transferring from one FTP server to another:
``$ touch ./data/intervent/data/from/test_1.txt``

3. Run Sidekiq scheduled worker
``$ bundle exec sidekiq -r ./lib/worker.rb``

5. After processing job file should be:
 - transferred to ``./data/intuity/data/to/test_1.txt`` 
 - moved to ``./data/intervent/data/history/test_1.txt``


