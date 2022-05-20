module TerraspaceCiGithub
  class Vars < Base
    # Hash of properties to store
    def data
      {
        build_system: "github",   # required
        host: host,
        full_repo: full_repo,
        branch_name: branch_name,
        # urls
        pr_url: pr_url,
        build_url: build_url,
        # additional properties
        build_type: build_type,   # required IE: pull_request or push
        pr_number: pr['number'],  # set when build_type=pull_request
        sha: sha,
        # additional properties
        commit_message: commit_message,
        build_id: build_id,
        build_number: ENV['GITHUB_RUN_NUMBER'],
      }
    end

    def host
      ENV['GITHUB_SERVER_URL'] || 'https://github.com'
    end

    def pr_url
      "#{host}/#{full_repo}/pull/#{pr['number']}" unless pr.empty?
    end

    def build_url
      "#{host}/#{full_repo}/actions/runs/#{build_id}"
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
