namespace :bundle do
  desc 'Audits Gemfile.lock for known vulnerabilities'
  task :audit do
    unless system('bundle-audit check --update')
      exit 1
    end
  end
end
