module TerraspaceCiGithub
  class Interface
    # required interface
    def vars
      Vars.new.data
    end

    # optional interface
    def comment(url)
      Pr.new.comment(url)
    end
  end
end
