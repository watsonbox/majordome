module Majordome
  class Agent
    $stdout.sync = true

    RESPONSES = {
      "switch on the television" => "okay I'll switch it on",
      "that's everything" => "sure",
      "exit" => "goodbye"
    }

    def initialize
      print "Initializing... ".colorize(:light_blue)

      # Initialize recognizers
      keyword_recognizer.decoder.ps_decoder
      grammar_recognizer.decoder.ps_decoder

      puts "[DONE]".colorize(:green)
    end

    def keyword_recognizer
      return @keyword_recognizer if @keyword_recognizer

      @keyword_recognizer = LiveSpeechRecognizer.new(
        Configuration::KeywordSpotting.new('Computer', 4)
      )
    end

    def grammar_recognizer
      return @grammar_recognizer if @grammar_recognizer

      @grammar_recognizer = LiveSpeechRecognizer.new(
        Configuration::Grammar.new do
          RESPONSES.each do |request, response|
            sentence request
          end
        end
      )
    end

    def listen
      puts "Listening...".colorize(:light_blue)

      loop do
        passive_listen
        active_listen or break
      end
    end

    def passive_listen
      keyword_recognizer.recognize do |speech|
        request "Computer?"
        respond_with "Yes?"
        break
      end
    end

    # Truthy to return to passive loop, falsy to exit
    def active_listen
      result = nil

      grammar_recognizer.recognize do |speech|
        request speech

        if response = RESPONSES[speech]
          respond_with response
        else
          puts ''
        end

        case speech
        when "that's everything"
          result = true
          break
        when "exit"
          result = false
          break
        end
      end

      result
    end

    def respond_with(text)
      puts ' => ' + text.capitalize.colorize(:green)
      `say "#{text}"`
    end

    def request(text)
      print text.capitalize.colorize(:light_blue)
    end
  end
end
