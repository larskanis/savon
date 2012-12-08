module Savon
  class Options

    GLOBAL = [

      # SOAP endpoint.
      :endpoint,

      # Proxy server to use for all requests.
      :proxy,

      # A Hash of HTTP headers.
      :headers,

      # Open timeout in seconds.
      :open_timeout,

      # Read timeout in seconds.
      :read_timeout,

      # Used by Savon to store the last response to pass
      # its cookies to the next request.
      :last_response,

      # XXX: not yet supported [dh, 2012-12-06]
      :raise_errors,
      :env_namespace,
      :soap_version,
      :soap_header,
      :hooks,
      :logger,
      :pretty_print_xml
    ]

    REQUEST  = [ :message, :xml ]

    SCOPES   = { :global => GLOBAL, :request => REQUEST }

    DEFAULTS = {
      :hooks        => lambda { Class.new { def fire(*) yield end }.new },
      :logger       => lambda { Class.new { def log(msg, *) end }.new },
      :soap_version => lambda { 1 }
    }

    SCOPES.each do |scope_sym, scope|
      scope.each do |option|
        define_method(option) { get(scope_sym, option) }
      end
    end

    def initialize
      @options = {}

      SCOPES.each do |scope, _|
        @options[scope] = {}
      end
    end

    def add(scope, option, value)
      validate_scope! scope
      validate_option! scope, option

      @options[scope][option] = value
    end

    def set(scope, options)
      validate_scope! scope
      validate_all_options! scope, options

      @options[scope] = options
    end

    def get(scope, option)
      validate_scope! scope
      validate_option! scope, option

      default_option = DEFAULTS[option]
      @options[scope][option] ||= default_option ? default_option.call : nil
    end

    private

    def validate_scope!(scope)
      unless SCOPES.include? scope
        raise ArgumentError, "Invalid option scope: #{scope.inspect}\n" \
                             "Available scopes: #{SCOPES.keys.inspect}"
      end
    end

    def validate_option!(scope, option)
      available_options = SCOPES[scope]

      unless available_options.include? option
        raise ArgumentError, "Unknown #{scope} option: #{option.inspect}\n" \
                             "Available options: #{available_options.inspect}"
      end
    end

    def validate_all_options!(scope, options)
      available_options = SCOPES[scope]
      unknown_options   = options.keys - available_options

      unless unknown_options.empty?
        raise ArgumentError, "Unknown #{scope} option(s): #{unknown_options.inspect}\n" \
                             "Available options: #{available_options.inspect}"
      end
    end

  end
end
