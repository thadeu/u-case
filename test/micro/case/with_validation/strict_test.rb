require 'test_helper'

if ENV.fetch('ACTIVEMODEL_VERSION', '6.1') <= '6.0.0'
  require 'u-case/with_validation'

  module Micro::Case
    module WithValidation
      class StrictTest < Minitest::Test
        class Multiply < Micro::Case::Strict
          attribute :a
          attribute :b
          validates :a, :b, presence: true, numericality: true

          def call!
            Success(number: a * b)
          end
        end

        class NumberToString < Micro::Case::Strict
          attribute :number
          validates :number, presence: true, numericality: true

          def call!
            Success(number.to_s)
          end
        end

        def test_success
          calculation = Multiply.new(a: 2, b: 2).call

          assert(calculation.success?)
          assert_equal(4, calculation.value[:number])
          assert_instance_of(Micro::Case::Result, calculation)

          # ---

          flow = Micro::Case::Flow[Multiply, NumberToString]

          assert_equal('4', flow.call(a: 2, b: 2).value)
        end

        def test_failure
          err1 = assert_raises(ArgumentError) { Multiply.call({}) }
          err2 = assert_raises(ArgumentError) { Multiply.call({a: 1}) }

          assert_equal('missing keywords: :a, :b', err1.message)
          assert_equal('missing keyword: :b', err2.message)

          # ---

          result = Multiply.new(a: 1, b: nil).call

          assert_result_failure(result)
          assert_equal(["can't be blank", 'is not a number'], result.value[:errors][:b])
          assert_instance_of(Micro::Case::Result, result)

          # ---

          result = Multiply.new(a: 1, b: 'a').call

          assert_result_failure(result)
          assert_equal(['is not a number'], result.value[:errors][:b])
          assert_instance_of(Micro::Case::Result, result)
        end
      end
    end
  end
end
