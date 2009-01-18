#
# Query Analyzer
#
#
# Original MySQL plugin:
# http://github.com/jeberly/query-analyzer
#
# PostgreSQL/Oracle Adapter by:
# http://spazidigitali.com/2006/12/01/rails-query-analyzer-plugin-now-also-on-oracle-and-postgresql/
#
# Usage:
#
#    config.gem "query_analyzer"
#
#
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module QueryAnalyzer
  VERSION = '0.1.2'
end

class Array
  protected
    def qa_columnized_row(fields, sized)
      row = []
      fields.each_with_index do |f, i|
        row << sprintf("%0-#{sized[i]}s", f.to_s)
      end
      row.join(' | ')
    end

  public

  def qa_columnized
    sized = {}
    self.each do |row|
      row.values.each_with_index do |value, i|
        sized[i] = [sized[i].to_i, row.keys[i].length, value.to_s.length].max
      end
    end

    table = []
    table << qa_columnized_row(self.first ? self.first.keys : "No Analysis Information", sized)
    table << '-' * table.first.length
    self.each { |row| table << qa_columnized_row(row.values, sized) }
    table.join("\n   ") # Spaces added to work with format_log_entry
  end
end

#
# Connection Adapters
#
module ActiveRecord
  module ConnectionAdapters

    #
    # MySQL
    #
    class MysqlAdapter < AbstractAdapter
      private
        alias_method :select_without_analyzer, :select

        def select(sql, name = nil)
          query_results = select_without_analyzer(sql, name)

          if @logger and @logger.level <= Logger::INFO
            @logger.debug(
              @logger.silence do
                format_log_entry("Analyzing #{name}\n",
                  "#{select_without_analyzer("explain #{sql}", name).qa_columnized}\n"
                )
              end
            ) if sql =~ /^select/i
          end
          query_results
        end
    end

    #
    # Oracle
    #
    class OracleAdapter < AbstractAdapter
        # Name of plan table, default value 'PLAN_TABLE'.
        cattr_accessor :plan_table_name
        @@plan_table_name = 'PLAN_TABLE'

        # Plan details to use:
        # BASIC ..... displays minimum information
        # TYPICAL ... displays most relevant information
        # SERIAL .... like TYPICAL but without parallel information
        # ALL ....... displays all information
        cattr_accessor :plan_details
        @@plan_details ='TYPICAL'

      private
        alias_method :select_without_analyzer, :select

        # Query to output the computed plan using the dbms_xplan package (available from Oracle 9i onwards)
        def plan_query
          "select plan_table_output from table(dbms_xplan.display('#{@@plan_table_name}',null,'#{@@plan_details}'))"
        end

        def select(sql, name = nil)
          query_results = select_without_analyzer(sql, name)

          if @logger and @logger.level <= Logger::INFO
            execute("explain plan for #{sql}", name)
            @logger.debug(
              @logger.silence do
                format_log_entry("Analyzing #{name}\n",
                 "#{select_without_analyzer(plan_query, name).qa_columnized}\n"
                )
              end
            ) if sql =~ /^select/i
          end
          query_results
        end
    end

    #
    # PostgreSQL
    #
    class PostgreSQLAdapter < AbstractAdapter
        # if true then uses the ANALYZE option which (from postgresql manual):
        #Carry out the command and show the actual run times.
        cattr_accessor :explain_analyze
        @@explain_analyze = nil

        #if true then uses the VERBOSE option which  (from postgresql manual):
        #Shows the full internal representation of the plan tree,
        #rather than just a summary. Usually this option is only
        #useful for specialized debugging purposes.
        #The VERBOSE output is either pretty-printed or not,
        #depending on the setting of the explain_pretty_print
        #configuration parameter.
        cattr_accessor :explain_verbose
      @@explain_verbose = nil

      private

        alias_method :select_without_analyzer, :select

        def select(sql, name = nil)
          query_results = select_without_analyzer(sql, name)

          if @logger and @logger.level <= Logger::INFO
           @logger.debug(@logger.silence do
             format_log_entry("Analyzing #{name}\n\n",
             "#{select_without_analyzer("explain #{'analyze' if @@explain_analyze} "+
             "#{'verbose' if @@explain_verbose} #{sql}", name).qa_columnized}\n")
           end) if sql =~ /^select/i
          end
        query_results
        end

    end

    #
    # SQLite / SQLite3
    #
    # Pretty useless... nothing to do on a sunday, you know...
    #
    class SQLiteAdapter < AbstractAdapter
      # Name of stats table, default value 'sqlite_stat1'.
      cattr_accessor :stat_table_name
      @@stat_table_name = 'sqlite_stat1'

       private
         alias_method :select_without_analyzer, :select

         def select(sql, name = nil)
           query_results = select_without_analyzer(sql, name)
           from_table = name.split(" ").first.downcase.pluralize
           select_without_analyzer("ANALYZE #{from_table}")

           if @logger and @logger.level <= Logger::INFO
             @logger.debug(
               @logger.silence do
                 format_log_entry("Analyzing #{name}\n",
                  "#{select_without_analyzer("SELECT * FROM #{@@stat_table_name} WHERE tbl LIKE \"#{from_table}\"", name).qa_columnized}\n")
               end) if sql =~ /^select/i
            end

          query_results

        end

    end

  end

end
