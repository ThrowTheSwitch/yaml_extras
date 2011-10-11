require 'spec_helper'

describe ObjectPathing do
  describe :apply_path do
    it "should return the value stored at the defined path" do
      object = { :a => [nil, {"b" => "you win"}]}
      path = [:a, 1, "b"]
      ObjectPathing.apply_path(object, path).should == "you win"
    end
  end

  describe :find_path_to_key do
    it "should identify the path to a key" do
      object = { :a => [nil, {"b" => "you win"}]}
      ObjectPathing.find_path_to_key("b", object).should == [:a, 1, "b"]
    end

    it "should be nil if there is no path to the key" do
      ObjectPathing.find_path_to_key("nope", {:a => []}).should be_nil
      ObjectPathing.find_path_to_key("nope", {:a => {}}).should be_nil
      ObjectPathing.find_path_to_key("nope", []).should be_nil
      ObjectPathing.find_path_to_key("nope", {}).should be_nil
    end
  end
end
