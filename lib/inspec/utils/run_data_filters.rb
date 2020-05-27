module Inspec
  module Utils
    #   RunDataFilters is a mixin for core Reporters and plugin reporters.
    # The methods operate on the run_data Hash (prior to any conversion to a
    # full RunData object).
    #   All methods here operate using the run_data accessor and modify
    # its contents in place (if needed).
    module RunDataFilters

      # Long name, but we want to be clear this operates on the Hash
      # This is the only method that client libraries need to call; any future
      # feature growth should be handled internally here.
      def apply_run_data_filters_to_hash
        @config[:runtime_config] = Inspec::Config.cached || {}
        apply_report_resize_options
      end

      # Apply options such as message truncation and removal of backtraces
      def apply_report_resize_options
        runtime_config = @config[:runtime_config]

        message_truncation = runtime_config[:reporter_message_truncation] || "ALL"
        trunc = message_truncation == "ALL" ? -1 : message_truncation.to_i
        include_backtrace = runtime_config[:reporter_backtrace_inclusion].nil? ? true : runtime_config[:reporter_backtrace_inclusion]

        @run_data[:profiles]&.each do |p|
          p[:controls].each do |c|
            c[:results]&.map! do |r|
              r.delete(:backtrace) unless include_backtrace
              if r.key?(:message) && r[:message] != "" && trunc > -1
                r[:message] = r[:message][0...trunc] + "[Truncated to #{trunc} characters]"
              end
              r
            end
          end
        end
      end
    end
  end
end
