require 'yaml'

module Xtrn
  class Directory

    DEFAULT_OPTS = {
      verbose: false
    }

    def initialize(config, executor, opts={})
      opts      = DEFAULT_OPTS.merge(opts)

      @config   = config
      @executor = executor
      @verbose  = opts[:verbose]
    end

    def revision(args, url)
      res = @executor.exec("svn info #{args.join(' ')} #{url}")
      YAML.load(res)['Last Changed Rev']
    end

    def do_upgrade(args, path)
      @executor.exec("svn upgrade #{args.join(' ')} #{path}")
    end

    def do_update(args, path)
      @executor.exec("svn update #{args.join(' ')} #{path}")
    end

    def do_checkout(args, url, path)
      rev = revision(args, url)
      @executor.exec("svn checkout #{args.join(' ')} -r#{rev} #{url} #{path}")
    end

    def update!
      @config.each do |entry|
        args = []
        url  = entry['url']
        path = entry['path']

        args << (entry['username'] ? "--username '#{entry['username']}'" : '')
        args << (entry['password'] ? "--password '#{entry['password']}'" : '')
        args << (entry['cache_credentials'] ? '' : '--no-auth-cache')

        if File.directory?(path)
          do_upgrade(args, path)
          do_update(args, path)
        else
          do_checkout(args, url, path)
        end
      end

      def updated_gitignore(original_gitignore)
        to_add = @config.map{|i|i['path']}
        
        original_gitignore.each_line do |line|
          line.strip!
          to_add.delete(line)
        end
        return original_gitignore if to_add.empty?
        [*original_gitignore.lines.map(&:"strip!"), *to_add].join("\n")
      end
    end
  end
end
