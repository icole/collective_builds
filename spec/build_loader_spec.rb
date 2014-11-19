require 'minitest/autorun'
require 'build_loader'

describe BuildLoader do

    it "should return correctly" do
      assert_equal BuildLoader.foo, "bar"
    end

  end
