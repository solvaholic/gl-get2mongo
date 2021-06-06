# gl-get2mongo

Enable key:value create/read/update/delete in MongoDB via Graylog HTTP JSONPath lookup table data adapter

:construction: This is a work-in-progress :construction:

## Quick start

1. Add gl-get2mongo to your Graylog stack
1. Create lookup table data adapters, caches, lookup tables
1. Create pipeline rules and pipeline(s)
1. Pause a moment and think "There should be a Content Pack for this"
1. I'm not sure what next, so: TODO

## It's a shim

Ideally, for me, Graylog's CSV lookup table data adapter would support adding and modifying data as well as reading it. Then I could store my lookup table in a .csv file and deal with performance if it becomes a problem.

The CSV adapter doesn't write, though. Neither does the HTTP JSONPath lookup table data adapter. So: Learn Java, prove a solution, discuss with the Graylog core team, and submit a pull request? Nah. That'd definitely scrach my itch, but too slowly. And it'd belie half my excuses.

gl-get2mongo is a shim that will, on one side, receive and respond to HTTP GET requests from Graylog's HTTP JSONPath lookup table data adapter and, on the other side, interact with a nearby MongoDB.

## Why: An itch, and two excuses

I want to receive logs from my DHCP and DNS servers and use those to maintain MAC:IP and IP:Hostname mappings. And I want to use those to enrich network flow data with context about local and remote hosts.

Probably there's already a solution for this. However, this is my excuse to use Graylog. And my excuse to practice creating something. It also scratches an itch: I want to see what's happening on my network, and I want to understand where the data come from.

## Thank You

I think this is my first Ruby project. MongoDB, too. For the scratch, and the itch, thank you :bow:

https://github.com/Graylog2

https://docs.mongodb.com/ruby-driver/master/

https://www.devdungeon.com/content/ruby-sinatra-tutorial
