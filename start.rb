require 'curb'
require 'nokogiri'
require 'csv'

Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }

abort('must be 2 arguments') if ARGV.length != 2

PetsFood.perform(ARGV[0], ARGV[1])
