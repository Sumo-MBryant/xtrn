require 'open3'

module Xtrn
  class Executor

    DEFAULT_OPTS = {
      verbose: false
    }

    def initialize(opts={})
      opts      = DEFAULT_OPTS.merge(opts)
      @verbose  = opts[:verbose]
    end

    def exec(cmd, ignore_failure=false)
      puts "Exec: #{cmd}" if @verbose

      stdout, stderr, status = Open3.capture3(cmd)

      unless status.success? or ignore_failure
        puts "Aborting due to execution error:\n#{stderr}"
        exit(1)
      end

      stdout
    end

  end
end
