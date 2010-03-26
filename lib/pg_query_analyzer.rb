module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      
      @@analyzer_debug = 0..2
      @@analyzer_warn  = 3..7

      def select_logger time_spent, log
        case time_spent
        when @@analyzer_debug then @logger.debug(log)
        when @@analyzer_warn  then @logger.warn(log)
        else @logger.fatal(log)
        end
      end

      # ANALYZE carries out the command and show the actual run times.
      @@explain_analyze = true # use nil to disable

      # VERBOSE shows the full plan tree, rather than a summary.
      @@explain_verbose = true # use nil to disable

      private

      alias_method :select_without_analyzer, :select

      def select(sql, name = nil)
        start_time = Time.now
        query_results = select_without_analyzer(sql, name)
        spent = Time.now - start_time

        if @logger and @logger.level <= Logger::INFO
          select_logger(@spent, @logger.silence do
           format_log_entry("Analyzing #{name} Execution Time: #{spent}\n\n",
           "#{select_without_analyzer("explain #{'analyze' if @@explain_analyze} "+
           "#{'verbose' if @@explain_verbose} #{sql}", name).map(&:values).join("\n ")}\n")
         end) if sql =~ /^select/i
        end
      query_results
      end
    end
  end
end