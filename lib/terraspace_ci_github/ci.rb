module TerraspaceCiGithub
  class Ci < Base
    # Interface method. Hash of properties to store
    def vars
      {
        branch_name: branch_name, # using
        build_id: build_id,
        build_number: ENV['GITHUB_RUN_NUMBER'],
        build_system: "github",   # using
        build_type: build_type,   # using
        build_url: build_url,
        commit_message: commit_message,
        full_repo: full_repo,     # using
        pr_number: pr_number,     # using
        sha: sha,                 # using
      }
    end

    # https://github.com/octokit/octokit.rb/blob/4-stable/lib/octokit/client/commits.rb#L150
    # https://docs.github.com/en/rest/commits/commits#get-a-commit
    def commit_message
      # return unless github_token?
      resp = client.commit(full_repo, sha)
      resp['commit']['message']
    end

    def build_id
      ENV['GITHUB_RUN_ID']
    end

    def build_url
      "https://github.com/#{full_repo}/actions/runs/#{build_id}"
    end

    def full_repo
      ENV['GITHUB_REPOSITORY']
    end

    def sha
      if build_type == "pull_request"
        pr.dig('pull_request','head','sha')
      else # push
        ENV['GITHUB_SHA']
      end
    end

    def build_type
      ENV['GITHUB_EVENT_NAME']
    end

    def branch_name
      if build_type == "pull_request"
        pr.dig('pull_request','head','ref')
      else # push
        ENV['GITHUB_REF']
      end
    end

    # GitHub webhook JSON payload in file and path is set in GITHUB_EVENT_PATH
    def pr
      return {} unless ENV['GITHUB_EVENT_PATH']
      JSON.load(IO.read(ENV['GITHUB_EVENT_PATH']))
    end

    def pr_number
      pr['number']
    end
  end
end
