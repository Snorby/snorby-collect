# snorby-collect

* [http://www.snorby.org][http://www.snorby.org]
* [Documentation][http://github.com/Snorby/snorby-collect]

## Description

The snorby collection agent is in charge of monitoring & process unified2 data. The data collected will be passed to the snorby web application for analysis and reporting.

## Features
	
 * Verbose & Debug Output
 * Multiple Adaptor Support. mysql, sqlite, sqlite::memory: and postgres. (more coming soon)
 * Signature, Classification & Generator Processing

	 The snorby collection agent will import all supplied configurations for database storage before unified2 processing begins. As a result
	 you gain slightly more efficient insert times. The configuration files MD5 will be stored in the sensor table and checked 
	 intermittently for changes. The downside to this approach is the initial import can be time consuming. This option can
	 be disabled if you favor of a more centralized management tool.

## Example Usage

	# Open/Create the snorby collection agent configuration file
	# snorby-collect --config
	
## Example Configuration File (YAML)
	
	# Snorby Collection Agent Configuration File

	# Sensor Configuration
	:sensor:
	  :interface: 'en1'
	  :name: 'TheMind.local'

	# Path: unified2 log file
	# Example: '/var/log/snort/merged.log'
	:unified2: '/var/log/snort/merged.log'

	# Path: sid-msg.map file
	# Example: '/etc/snort/sid-msg.map'
	:signatures: '/Users/mephux/.snort/etc/sid-msg.map'

	# Path: gen-msg.map file
	# Example: '/etc/snort/gen-msg.map'
	:generators: '/Users/mephux/.snort/etc/gen-msg.map'

	# Path: classification.config file
	# Example: '/etc/snort/classification.config'
	:classifications: '/Users/mephux/.snort/etc/classification.config'

	:database:
	  :adapter: 'mysql' # sqlite, sqlite::memory:, mysql, postgres
	  :database: 'rUnified2'
	  :username: 'rUnified2'
	  :password: 'password'
	  :host: 'localhost'

## Then...

	# Run the snorby collection agent without daemonizing 
	# Good for testing that configuration file.
	$ snorby-collect --run --debug
	
	# Run snorby collection as a daemon
	$ snorby-collect -d --quiet

## Requirements
	
 * unified2: ~> 0.2.0
 * datamapper: ~> 1.0.2
 * env: ~> 0.1.2
 * ruby-progressbar: ~ 0.9
 * daemon-spawn: ~> 0.4.1
	
## Install

	$ gem install snorby-collect

## Copyright

Copyright (c) 2011 Dustin Willis Webber

See LICENSE.txt for details.
