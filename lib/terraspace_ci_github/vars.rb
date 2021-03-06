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
        branch_url: branch_url,
        # additional properties
        build_type: build_type,   # required IE: pull_request or push
        pr_number: pr_number,  # set when build_type=pull_request
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

    def branch_url
      "#{host}/#{full_repo}/tree/#{branch_name}" if branch_name
    end

    COMMIT_PATTERN = %r{Merge pull request #(\d) from (.*)}
    def pr_url
      if pr['number']
        "#{host}/#{full_repo}/pull/#{pr['number']}"
      elsif md = commit_message.match(COMMIT_PATTERN)
        # git push commit has commit with PR info
        # IE: Merge pull request #4 from tongueroo/feature
        number = md[1]
        org_branch = md[2]
        org = org_branch.split('/').first
        repo = ENV['GITHUB_REPOSITORY'].split('/').last # IE: tongueroo/infra-ci
        "#{host}/#{org}/#{repo}/pull/#{number}"
      end
    end

    def pr_number
      if pr['number']
        pr['number']
      elsif md = commit_message.match(COMMIT_PATTERN)
        md[1] # number
      end
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
    rescue Octokit::Unauthorized => e
      puts "WARN: #{e.message}. Error getting commit message. Please double check your github token"
    end
    memoize :commit_message

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
        ENV['GITHUB_REF_NAME']
      end
    end

    # GitHub webhook JSON payload in file and path is set in GITHUB_EVENT_PATH
    def pr
      return {} unless ENV['GITHUB_EVENT_PATH']
      JSON.load(IO.read(ENV['GITHUB_EVENT_PATH']))
    end
  end
end
