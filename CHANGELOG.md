## 3.0.8
  - Update gemspec summary

## 3.0.7
  - Fix some documentation issues

## 3.0.6
  - Docs: Add plugin description

## 3.0.5
  - Docs: Bump patch level for doc build

## 3.0.4
  - A `logger.debug` statement was crashing because of a type mismatch

## 3.0.3
  - Correctly merges the headers before sending the events and fix an undefined `event` variables #13, #14

## 3.0.2
  - Relax constraint on logstash-core-plugin-api to >= 1.60 <= 2.99

## 3.0.1
  - Fix a data loss issue when shutting down logstash #8
  - Move from receive to `multi_receive` api and send events per batch #9
  - Allow to send custom header #3
   
## 3.0.0 (2016-05-20)
  - Breaking: Updated to use new Java APIs
  
## 2.0.4
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
  
## 2.0.3
  - New dependency requirements for logstash-core for the 5.0 release

## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

