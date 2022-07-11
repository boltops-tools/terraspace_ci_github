module TerraspaceCiGithub
  class Interface
    # required interface
    def vars
      Vars.new.data
    end

    # optional interface
    def comment(url)
      puts "DEPRECATED: The comment interface has been replaced by the terraspace_vcs_github gem."
      puts "Please upgrade your terraspace install and add terraspace_vcs_github to your Terraspace project Gemfile."
      puts "The comment interface method will be removed from terraspace."
      Pr.new.comment(url)
    end
  end
end
