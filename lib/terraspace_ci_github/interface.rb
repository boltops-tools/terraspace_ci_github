module TerraspaceCiGithub
  class Interface
    # required interface
    def vars
      Ci.new.vars
    end

    # optional interface
    def comment(url)
      Pr.new.comment(url)
    end
  end
end
