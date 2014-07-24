#!/usr/bin/env ruby

require 'optparse'
require 'rack'
require 'pathname'
require 'open3'
options = {root: "root", port: 8080}
OptionParser.new do |opts|
    opts.banner = "Usage: clapi [options]"

    opts.on("-r", "--root DIRECTORY", "Root directory to run clapy") do |r|
        options[:root] = r
    end
    opts.on("-p", "--port PORT", "Port to run on") do |p|
        options[:port] = p
    end

end.parse!


class CliApp
    def initialize(options)
        @options = options
    end
    def call(env)
        path = env['PATH_INFO']
        query = env['QUERY_STRING']
        method = env['REQUEST_METHOD']
        pn = Pathname.new([@options[:root], path].join('/'))
        pn = Pathname.new(pn.cleanpath)
        
        if not pn.exist?
            return [404, {'Content-Type' => 'text/html'}, ["404 - Not Found\n<br>\n", pn.to_s]]
        end
        stdin, stdout, stderr, wait_thr = Open3.popen3(pn.join(method).to_s, query)
        content = []
        content = stdout.gets(nil) || ""
        content = content.split(/\r?\n/)
        stderr.gets(nil)
        exit_code = wait_thr.value.exitstatus
        headers = {}
        
        content.each { |h|
            break if h.empty?
            header = h.split
            headers[header[0]] = header[1]
        }
        content.shift headers.length + 1
        return [exit_code, headers, content]
    end

end

app = CliApp.new(options)
Rack::Handler::WEBrick.run app, Port: options[:port]
