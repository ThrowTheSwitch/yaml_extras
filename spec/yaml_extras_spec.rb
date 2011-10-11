require 'spec_helper'

describe ObjectPathing do
  describe :apply_path do
    it "should return the value stored at the defined path" do
      object = { :a => [ nil, { "b" => "you win" } ] }
      path = [ :a, 1, "b" ]
      ObjectPathing.apply_path(object, path).should == "you win"
    end
  end

  describe :find_paths_to_keys do
    it "should identify the path to one key" do
      object = { :a => [ nil, { "b" => "you win" } ] }
      paths = ObjectPathing.find_paths_to_keys(["b"], object)
      paths.should include([:a, 1, "b"])
      paths.length.should == 1
    end

    it "should identify the paths to one key multiple times" do
      object = { :a => [ nil, { "b" => "you win" } ],
                 :b => [ nil, nil, { "b" => "you win again" } ],
                 "b" => "you just keep winning" }
      paths = ObjectPathing.find_paths_to_keys(["b"], object)
      paths.should include(
          [:a, 1, "b"],
          [:b, 2, "b"],
          ["b"]
        )
      paths.length.should == 3
    end

    it "should identiy the paths to multiple keys multiple times" do
      object = { :a => [ nil, { "a" => "you win" } ],
                 :b => [ nil, nil, { :a => "you win again" } ],
                 :c => [ nil, nil, { "a" => "you win yet again" } ] }
      paths = ObjectPathing.find_paths_to_keys([:a, "a"], object)
      
      paths.should include(
          [:a],
          [:b, 2, :a],
          [:a, 1, "a"],
          [:c, 2, "a"]
        )
      paths.length.should == 4
    end

    it "should be an empty list if there is no path to the key" do
      ObjectPathing.find_paths_to_keys(["nope"], {:a => []}).should == []
      ObjectPathing.find_paths_to_keys(["nope"], {:a => {}}).should == []
      ObjectPathing.find_paths_to_keys(["nope"], []).should == []
      ObjectPathing.find_paths_to_keys(["nope"], {}).should == []
    end
  end
end

describe YamlExtras do
  describe :initialize do
    it "should record the original object" do
      mock(File).read("some_file.yml") {"---\na: 5\n"}
      YamlExtras.new("some_file.yml").original.should == {"a" => 5}
    end
  end

  describe :integrate_includes do
    it "should be hash with INCLUDEs integrated" do
      other = "---\nb: 2\n"
      input = "---\na: 1\nINCLUDE: other.yml\n"
      expect = { "a" => 1, "b" => 2 }
      
      mock(File).read("some_file.yml") { input }
      mock(File).read("other.yml") { other }

      ye = YamlExtras.new("some_file.yml").integrate_includes.should == expect
    end
  end
end
