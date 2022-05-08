module TerraspaceCiGithub
  class Vars < Base
    # Hash of properties to store
    def data
      {
        build_system: "github",   # required
        full_repo: full_repo,     # required
        branch_name: branch_name, # using
        commit_url: commit_url,
        branch_url: branch_url,
        pr_url: pr_url,
        build_url: build_url,
        # additional properties
        build_type: build_type,   # IE: pull_request or push
        commit_message: commit_message,
        build_id: build_id,
        build_number: ENV['GITHUB_RUN_NUMBER'],
        pr_number: pr['number'],  # using
        sha: sha,                 # using
      }
    end

    def commit_url
      "#{domain}/#{full_repo}/commit/#{sha}"
    end

    def branch_url
      "#{domain}/#{full_repo}/tree/#{branch_name}"
    end

    def pr_url
      "#{domain}/#{full_repo}/pull/#{pr['number']}" if pr
    end

    def build_url
      "#{domain}/#{full_repo}/actions/runs/#{build_id}"
    end

    def domain
      ENV['GITHUB_DOMAIN'] || 'https://github.com'
    end

    def build_id
      ENV['GITHUB_RUN_ID']
    end

    # https://github.com/octokit/octokit.rb/blob/4-stable/lib/octokit/client/commits.rb#L150
    # https://docs.github.com/en/rest/commits/commits#get-a-commit
    def commit_message
      return unless github_token?
      resp = client.commit(full_repo, sha)
      resp['commit']['message']
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
  end
end
