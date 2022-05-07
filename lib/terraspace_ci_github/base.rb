require "octokit"

module TerraspaceCiGithub
  class Base
    extend Memoist

    def client
      Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    end
    memoize :client

    def github_token?
      if ENV['GITHUB_TOKEN']
        true
      else
        puts "WARN: The env var GITHUB_TOKEN is not configured. Will not post PR comment"
        false
      end
    end
  end
end
