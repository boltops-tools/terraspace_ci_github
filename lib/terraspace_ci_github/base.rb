require "faraday"
require "faraday/retry"
require "octokit"

module TerraspaceCiGithub
  class Base
    extend Memoist

    def client
      Octokit::Client.new(access_token: ENV['GH_TOKEN'])
    end
    memoize :client

    def github_token?
      if ENV['GH_TOKEN']
        true
      else
        puts "WARN: The env var GH_TOKEN is not configured. Will not post PR comment"
        false
      end
    end
  end
end
