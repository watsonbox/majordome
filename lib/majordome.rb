require 'colorize'
require 'pocketsphinx-ruby'
include Pocketsphinx

require "majordome/version"
require "majordome/agent"

Pocketsphinx.disable_logging

module Majordome
  def self.listen
    Agent.new.listen
  end
end
