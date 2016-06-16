## 2.0.5
  - Fix a data loss issue when shutting down logstash #8
  - Move from receive to `multi_receive` api and send events per batch #9
  - Allow to send custom header #3
  
## 2.0.4
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash

## 2.0.3
  - New dependency requirements for logstash-core for the 5.0 release
  
## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

