##Usage

	local Growl = require 'growl'

	Growl.new('This is normal message')

	Growl.new('This is error message', 'error')

	Growl.new('This is info message', 'info')

	Growl.new('This is custom message', nil, 200, 12)

