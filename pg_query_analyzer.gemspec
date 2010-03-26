# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pg_query_analyzer}
  s.version = "0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Trevor Turk"]
  s.date = %q{2010-03-24}
  s.description = %q{Provides a PostgreSQL query analysis in your development logs.}
  s.email = %q{trevorturk@gmail.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["lib/pg_query_analyzer.rb", "README"]
  s.homepage = %q{http://github.com/trevorturk/pg_query_analyzer}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Provides a PostgreSQL query analysis in your development logs.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
