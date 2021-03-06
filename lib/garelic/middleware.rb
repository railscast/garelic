class Garelic::Middleware
  def initialize(app)
    @app = app
    Garelic::Metrics.reset!
  end

  def call(env)
    status, headers, response = @app.call(env)

    if headers["Content-Type"] =~ /text\/html|application\/xhtml\+xml/ \
        and response.respond_to?(:body) \
        and response.body.respond_to?(:gsub)
      body = response.body.gsub(Garelic::Timing, Garelic.report_user_timing_from_metrics(Garelic::Metrics))
      response = [body]
    end

    Garelic::Metrics.reset!

    [status, headers, response]
  end
end