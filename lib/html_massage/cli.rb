require 'thor'
require 'rest-client'
require File.expand_path File.join(File.dirname(__FILE__), '..', 'html_massage')


module HtmlMassager

  class CLI < Thor

    MOBILE_USER_AGENT = "Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Mobile Safari/535.19"

    desc :html, 'Download HTML from given URL and massage into html'
    def html url
      STDOUT.puts massage_to :html, url
    end

    desc :text, 'Download HTML from given URL and massage into plain text'
    def text url
      STDOUT.puts massage_to :text, url
    end

    desc :markdown, 'Download HTML from given URL and massage into markdown'
    def markdown url
      STDOUT.puts massage_to :markdown, url
    end

    no_tasks do
      def massage_to output_format, url
        HtmlMassage.send output_format,
                         RestClient.get(url, :user_agent => MOBILE_USER_AGENT),
                         :source_url => url,
                         :links => :absolute,
                         :images => :absolute
      end
    end

  end
end
