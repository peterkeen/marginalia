require 'rack/deflater'

module Rack
  class Deflater
    def call(env)
      status, headers, body = @app.call(env)
      headers = Utils::HeaderHash.new(headers)

      # Skip compressing empty entity body responses and responses with
      # no-transform set.
      if Utils::STATUS_WITH_NO_ENTITY_BODY.include?(status) ||
          headers['Cache-Control'].to_s =~ /\bno-transform\b/
        return [status, headers, body]
      end

      request = Request.new(env)

      encoding = Utils.select_best_encoding(%w(gzip deflate identity),
                                            request.accept_encoding)

      # Set the Vary HTTP header.
      vary = headers["Vary"].to_s.split(",").map { |v| v.strip }
      unless vary.include?("*") || vary.include?("Accept-Encoding")
        headers["Vary"] = vary.push("Accept-Encoding").join(",")
      end

      case encoding
      when "gzip"
        headers['Content-Encoding'] = "gzip"
        headers.delete('Content-Length')
        mtime = headers.key?("Last-Modified") ?
          Time.httpdate(headers["Last-Modified"]) : Time.now
        [status, headers, GzipStream.new(body, mtime)]
      when "deflate"
        headers['Content-Encoding'] = "deflate"
        headers.delete('Content-Length')
        [status, headers, DeflateStream.new(body)]
      when "identity"
        [status, headers, body]
      when nil
        body.close if body.respond_to?(:close)   # --- ONLY ADDITION TO THE STOCK METHOD ---
        message = "An acceptable encoding for the requested resource #{request.fullpath} could not be found."
        [406, {"Content-Type" => "text/plain", "Content-Length" => message.length.to_s}, [message]]
      end
    end

    class GzipStream
      def each(&block)
        @writer = block
        @gzip = ::Zlib::GzipWriter.new(self)
        @gzip.mtime = @mtime
        @body.each { |part|
          @gzip.write(part)
          @gzip.flush
        }
      ensure
        @body.close if @body.respond_to?(:close)
        @gzip.close
        @writer = nil
      end

      def close
        @body.close if @body.respond_to?(:close)
        @gzip.close if @gzip && !@gzip.closed?
      end
    end

    class DeflateStream
      def each
        @deflater = ::Zlib::Deflate.new(*DEFLATE_ARGS)
        @body.each { |part| yield @deflater.deflate(part, Zlib::SYNC_FLUSH) }
        yield @deflater.finish
        nil
      ensure
        @body.close if @body.respond_to?(:close)
      end

      def close
        @body.close if @body.respond_to?(:close)
        @deflater.close if @deflater && !@deflater.closed?
      end
    end
  end
end
