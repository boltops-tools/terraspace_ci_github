# frozen_string_literal: true

require "terraspace_ci_github/autoloader"
TerraspaceCiGithub::Autoloader.setup

require "json"
require "memoist"

module TerraspaceCiGithub
  class Error < StandardError; end
end

Terraspace::Cloud::Ci.register(
  name: "github",
  env_key: "GITHUB_ACTIONS",
  interface_class: TerraspaceCiGithub::Interface,
  template_root: File.expand_path("#{__dir__}/template"),
)
