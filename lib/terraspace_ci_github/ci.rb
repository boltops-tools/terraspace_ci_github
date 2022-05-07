module TerraspaceCiGithub
  class Ci
    # Interface method. Hash of properties to store
    def vars
      {
        branch_name: branch_name,
        build_id: build_id,
        build_number: ENV['GITHUB_RUN_NUMBER'],
        build_system: "github",
        build_type: build_type,
        build_url: build_url,
        # commit_message: ENV['XXX'],
        pr_number: pr_number,
        sha: sha,
      }
    end

    def build_id
      ENV['GITHUB_RUN_ID']
    end

    def build_url
      # TODO: get right build_id using api
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
