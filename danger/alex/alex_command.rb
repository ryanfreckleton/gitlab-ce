require_relative '../../lib/gitlab/popen'

class AlexCommand
  Result = Struct.new(:stdout, :stderr, :status)

  def self.from_paths(paths)
    execute(%W[node_modules/.bin/alex #{paths.join(' ')}])
  end

  def self.from_text(text)
    execute(%W[node_modules/.bin/alex --stdin], text)
  end

  private

  def self.execute(cmd, input = nil)
    Open3.popen3({}, *cmd) do |stdin, stdout, stderr, wait_thr|
      stdin.puts(input)
      stdin.flush

      # stderr and stdout pipes can block if stderr/stdout aren't drained: https://bugs.ruby-lang.org/issues/9082
      # Mimic what Ruby does with capture3: https://github.com/ruby/ruby/blob/1ec544695fa02d714180ef9c34e755027b6a2103/lib/open3.rb#L257-L273
      out_reader = Thread.new { stdout.read }
      err_reader = Thread.new { stderr.read }

      yield(stdin) if block_given?
      stdin.close

      Result.new(out_reader.value, err_reader.value, wait_thr.value)
    end
  end
end
