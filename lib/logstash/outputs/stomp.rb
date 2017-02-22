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

  # this output is thread-safe
  concurrency :shared

  private
  def connect
    begin
      conn_hash = { :hosts => [
          {:login => @user, :passcode => @password.value,
           :host => @host, :port => @port},
        ],
        :reliable => true
      }
      @client = Stomp::Client.new(conn_hash)
      @logger.debug("Connected to stomp server") if @client.open?
    rescue => e
      @logger.debug("Failed to connect to stomp server, will retry",
                    :exception => e, :backtrace => e.backtrace)
      sleep 2
      retry
    end
  end


  public
  def register
    require "stomp"

    connect
  end # def register

  public
  def close
    @logger.warn("Disconnecting from stomp broker")
    @client.close
  end # def close

  def multi_receive(events)

    tx_name = "tx-#{Random.rand(2**32..2**64-1)}"
    @logger.debug("sending #{events.length} events in transaction #{tx_name}")

    begin
      @client.begin tx_name
      events.each do |event|
        headers = Hash.new(:transaction => tx_name)
        if @headers
          @headers.each do |k,v|
            headers[k] = event.sprintf(v)
          end
        end

        @client.publish(event.sprintf(@destination), event.to_json, headers)
      end
      @client.commit tx_name
    rescue Exception => exception
      @logger.error("Error while sending #{events.length} events in transaction #{tx_name}", :error => exception)
    end

  end # def multi_receive
end # class LogStash::Outputs::Stomp
