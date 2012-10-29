
git "/tmp/whisper" do
  repository "https://github.com/graphite-project/whisper.git"
  reference "0.9.10"
  action :sync
end

execute "install whisper" do
  command "python setup.py install"
  cwd "/tmp/whisper"
  action :run
end