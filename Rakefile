%w[rubygems rake rake/clean fileutils newgem rubigen activerecord].each { |f| require f }
require File.dirname(__FILE__) + '/lib/query_analyzer'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('query_analyzer', QueryAnalyzer::VERSION) do |p|
  p.developer('Marcos Piccinini', 'x@nofxx.com')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.post_install_message = 'PostInstall.txt'
  p.rubyforge_name       = p.name
  p.description          = "Append sql explain statements to your rails console/log files."
  p.summary              = "Append sql explain statements to your rails console/log files."
  p.url                  = "http://github.com/nofxx/query_analyzer"
  p.extra_deps         = [
    ['activerecord','>= 1.2.3'],
  ]
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]

  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]
