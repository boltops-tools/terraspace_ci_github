require "octokit"

module TerraspaceCiGithub
  class Pr
    def comment(url)
      return unless ENV['GITHUB_EVENT_NAME'] == 'pull_request'
      return unless github_token?

      repo = ENV['GITHUB_REPOSITORY'] # org/repo
      number = ENV['GITHUB_REF_NAME'].split('/').first # IE: 2/merge
      marker = "<!-- terraspace marker -->"
      body = marker + "\n"
      body << "Terraspace Cloud Url #{url}"

      puts "Adding comment to repo #{repo} number #{number}"

      comments = client.issue_comments(repo, number)
      # TODO: handle not found. Examples:
      # token is not valid
      # token is not right repo
      # todo are we allow to post comment on public repo without need the permission?
      found_comment = comments.find do |comment|
        comment.body.starts_with?(marker)
      end

      if found_comment
        client.update_comment(repo, found_comment.id, body) unless found_comment.body == body
      else
        client.add_comment(repo, number, body)
      end
    end

    def client
      @client ||= Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
    end

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
