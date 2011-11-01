module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      
      @@analyzer_debug = 0..2
      @@analyzer_warn  = 3..7

      def select_logger time_spent, message
        case time_spent
        when @@analyzer_debug then @logger.debug(message)
        when @@analyzer_warn  then @logger.warn(message)
        else @logger.fatal(message)
        end
      end

      # ANALYZE carries out the command and show the actual run times.
      @@explain_analyze = true # use nil to disable

      # VERBOSE shows the full plan tree, rather than a summary.
      @@explain_verbose = true # use nil to disable

      protected
      
      alias_method :log_without_analyzer, :log
      
      def log(sql, name = "SQL", binds = [], &block)
        start_time = Time.now
        query_results = log_without_analyzer(sql, name, binds, &block)
        spent = Time.now - start_time
        debugger
        if @logger and @logger.level <= Logger::INFO
          if sql.strip =~ /^select/i
            explain_query = "explain #{'analyze' if @@explain_analyze} " +
              "#{'verbose' if @@explain_verbose} #{sql}"
            message = nil
            @logger.silence do
              analyze_results = exec_cache(explain_query, []) 
              message = "Analyzing #{name} Execution Time: #{spent}\n\n"
              message << analyze_results.map(&:values).join("\n ")
            end
            select_logger(spent, message)
          end
        end
        query_results
      end
      
    end
  end
end