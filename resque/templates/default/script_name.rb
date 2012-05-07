class ScriptName
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] =~ /^\/<%= node[:resque_web][:service_name] %>/
       env["PATH_INFO"].sub!(/^\/<%= node[:resque_web][:service_name] %>/, '')
       env['SCRIPT_NAME'] = '/<%= node[:resque_web][:service_name] %>'
    end
    @app.call(env)
  end
end
