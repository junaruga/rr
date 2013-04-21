dir = File.dirname(__FILE__)
require 'forwardable'

require "#{dir}/rr/core_ext/enumerable"
require "#{dir}/rr/core_ext/hash"
require "#{dir}/rr/core_ext/array"
require "#{dir}/rr/core_ext/range"
require "#{dir}/rr/core_ext/regexp"

require "#{dir}/rr/class_instance_method_defined"
require "#{dir}/rr/blank_slate"

require "#{dir}/rr/errors"
require "#{dir}/rr/errors/rr_error"
require "#{dir}/rr/errors/subject_does_not_implement_method_error"
require "#{dir}/rr/errors/subject_has_different_arity_error"
require "#{dir}/rr/errors/double_definition_error"
require "#{dir}/rr/errors/double_not_found_error"
require "#{dir}/rr/errors/double_order_error"
require "#{dir}/rr/errors/times_called_error"
require "#{dir}/rr/errors/spy_verification_errors/spy_verification_error"
require "#{dir}/rr/errors/spy_verification_errors/double_injection_not_found_error"
require "#{dir}/rr/errors/spy_verification_errors/invocation_count_error"

require "#{dir}/rr/space"

require "#{dir}/rr/double_definitions/strategies/strategy"
require "#{dir}/rr/double_definitions/strategies/strategy_methods"
require "#{dir}/rr/double_definitions/strategies/verification/verification_strategy"
require "#{dir}/rr/double_definitions/strategies/verification/mock"
require "#{dir}/rr/double_definitions/strategies/verification/stub"
require "#{dir}/rr/double_definitions/strategies/verification/dont_allow"
require "#{dir}/rr/double_definitions/strategies/implementation/implementation_strategy"
require "#{dir}/rr/double_definitions/strategies/implementation/reimplementation"
require "#{dir}/rr/double_definitions/strategies/implementation/strongly_typed_reimplementation"
require "#{dir}/rr/double_definitions/strategies/implementation/proxy"
require "#{dir}/rr/double_definitions/strategies/double_injection/double_injection_strategy"
require "#{dir}/rr/double_definitions/strategies/double_injection/instance"
require "#{dir}/rr/double_definitions/strategies/double_injection/any_instance_of"
require "#{dir}/rr/adapters/rr_methods"
require "#{dir}/rr/double_definitions/double_injections/instance"
require "#{dir}/rr/double_definitions/double_injections/any_instance_of"
require "#{dir}/rr/double_definitions/double_definition"

require "#{dir}/rr/injections/injection"
require "#{dir}/rr/injections/double_injection"
require "#{dir}/rr/injections/method_missing_injection"
require "#{dir}/rr/injections/singleton_method_added_injection"
require "#{dir}/rr/method_dispatches/base_method_dispatch"
require "#{dir}/rr/method_dispatches/method_dispatch"
require "#{dir}/rr/method_dispatches/method_missing_dispatch"
require "#{dir}/rr/hash_with_object_id_key"
require "#{dir}/rr/recorded_calls"
require "#{dir}/rr/proc_from_block"

require "#{dir}/rr/double_definitions/double_definition_create_blank_slate"
require "#{dir}/rr/double_definitions/double_definition_create"
require "#{dir}/rr/double_definitions/child_double_definition_create"

require "#{dir}/rr/double"
require "#{dir}/rr/double_matches"

require "#{dir}/rr/expectations/argument_equality_expectation"
require "#{dir}/rr/expectations/any_argument_expectation"
require "#{dir}/rr/expectations/times_called_expectation"

require "#{dir}/rr/wildcard_matchers/anything"
require "#{dir}/rr/wildcard_matchers/is_a"
require "#{dir}/rr/wildcard_matchers/numeric"
require "#{dir}/rr/wildcard_matchers/boolean"
require "#{dir}/rr/wildcard_matchers/duck_type"
require "#{dir}/rr/wildcard_matchers/satisfy"
require "#{dir}/rr/wildcard_matchers/hash_including"

require "#{dir}/rr/times_called_matchers/terminal"
require "#{dir}/rr/times_called_matchers/non_terminal"
require "#{dir}/rr/times_called_matchers/times_called_matcher"
require "#{dir}/rr/times_called_matchers/never_matcher"
require "#{dir}/rr/times_called_matchers/any_times_matcher"
require "#{dir}/rr/times_called_matchers/integer_matcher"
require "#{dir}/rr/times_called_matchers/range_matcher"
require "#{dir}/rr/times_called_matchers/proc_matcher"
require "#{dir}/rr/times_called_matchers/at_least_matcher"
require "#{dir}/rr/times_called_matchers/at_most_matcher"

require "#{dir}/rr/spy_verification_proxy"
require "#{dir}/rr/spy_verification"

require "#{dir}/rr/adapters/rspec/invocation_matcher"

require "#{dir}/rr/version"

module RR
  class << self
    ADAPTER_NAMES = [
      :RSpec1,
      :RSpec2,
      :TestUnit1,
      :TestUnit2ActiveSupport,
      :TestUnit2,
      :MiniTestActiveSupport,
      :MiniTest
    ]

    include Adapters::RRMethods

    (RR::Space.instance_methods - Object.instance_methods).each do |method_name|
      class_eval((<<-METHOD), __FILE__, __LINE__ + 1)
        def #{method_name}(*args, &block)
          RR::Space.instance.__send__(:#{method_name}, *args, &block)
        end
      METHOD
    end

    def adapters
      @adapters ||= ADAPTER_NAMES.map { |adapter_name|
        [adapter_name, RR::Adapters.const_get(adapter_name).new]
      }
    end

    def find_applicable_adapters
      @applicable_adapters ||= begin
        applicable_adapters = adapters.inject([]) { |arr, (_, adapter)|
          arr << adapter if adapter.applies?
          arr
        }
        if applicable_adapters.empty?
          applicable_adapters << adapters.index(:None)
        end
        applicable_adapters
      end
    end

    def autohook
      RR.find_applicable_adapters.each do |adapter|
        #puts "Using adapter: #{adapter.name}"
        adapter.hook
      end
    end
  end
end

require "#{dir}/rr/adapters/rspec_1"
require "#{dir}/rr/adapters/rspec_2"
require "#{dir}/rr/adapters/test_unit_1"
require "#{dir}/rr/adapters/test_unit_2"
require "#{dir}/rr/adapters/test_unit_2_active_support"
require "#{dir}/rr/adapters/minitest"
require "#{dir}/rr/adapters/minitest_active_support"
require "#{dir}/rr/adapters/none"

RR.autohook

