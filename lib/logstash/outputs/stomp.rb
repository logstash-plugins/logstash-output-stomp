# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"


class LogStash::Outputs::Stomp < LogStash::Outputs::Base
  config_name "stomp"

  # The address of the STOMP server.
  config :host, :validate => :string, :required => true

  # The port to connect to on your STOMP server.
  config :port, :validate => :number, :default => 61613

  # The username to authenticate with.
  config :user, :validate => :string, :default => ""

  # The password to authenticate with.
  config :password, :validate => :password, :default => ""

  # The destination to read events from. Supports string expansion, meaning
  # `%{foo}` values will expand to the field value.
  #
  # Example: "/topic/logstash"
  config :destination, :validate => :string, :required => true

  # The vhost to use
  config :vhost, :validate => :string, :default => nil

  # Custom headers to send with each message. Supports string expansion, meaning
  # %{foo} values will expand to the field value.
  #
  # Example: headers => ["amq-msg-type", "text", "host", "%{host}"]
  config :headers, :validate => :hash

  # Enable debugging output?
  config :debug, :validate => :boolean, :default => false

  # Specify a custom X.509 CA (.pem certs), if needed
  config :cacert, :validate => :path

  # Specify a client certificate , if needed
  config :client_cert, :validate => :path

  # Specify a client certificate encryption key, if needed
  config :client_key, :validate => :path

  # Validate TLS/SSL certificate?
  config :ssl_certificate_validation, :validate => :boolean, :default => true

  # The connection type of your STOMP server.
  config :protocol, :validate => :string, :default => "stomp"

  private
  def connect
    begin
      @client.connect
      @logger.debug("Connected to stomp server") if @client.connected?
    rescue => e
      @logger.debug("Failed to connect to stomp server, will retry",
                    :exception => e, :backtrace => e.backtrace)
      sleep 2
      retry
    end
  end


  public
  def register
    require "onstomp"
    @ssl_opts = {}
    @ssl_opts[:ca_file] = @cacert if @cacert
    @ssl_opts[:cert] = @client_cert if @client_cert
    @ssl_opts[:key] = @client_key if @client_key
    # disable verification if false
    if !@ssl_certificate_validation
      @ssl_opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
      @ssl_opts[:post_connection_check] = false
    end
    @client = OnStomp::Client.new("#{@protocol}://#{@host}:#{@port}", :login => @user, :passcode => @password.value, :ssl => @ssl_opts)
    @client.host = @vhost if @vhost

    # Handle disconnects
    @client.on_connection_closed {
      connect
    }

    connect
  end # def register

  public
  def close
    @logger.warn("Disconnecting from stomp broker")
    @client.disconnect if @client.connected?
  end # def close

  def multi_receive(events)

    @logger.debug("stomp sending events in batch", { :host => @host, :events => events.length })

    @client.transaction do |t|
      events.each { |event|
        headers = Hash.new
        if @headers
          @headers.each do |k,v|
            headers[k] = event.sprintf(v)
          end
        end

        t.send(event.sprintf(@destination), event.to_json, headers)
      }
    end
  end # def receive
end # class LogStash::Outputs::Stomp
