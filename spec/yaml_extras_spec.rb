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
    it "should record the file name" do
      YamlExtras.new("some_file.yml").file_name.should == "some_file.yml"
    end
  end

  describe :original do
    it "should cache and return the Hash representing the loaded YAML file" do
      mock(File).read("some_file.yml") {"---\na: 5\n"}
      ye = YamlExtras.new("some_file.yml")
      ye.original.should == {"a" => 5}
      ye.original.should == {"a" => 5}
    end
  end

  describe :result do
    it "should cache and return the result of applying integrate_includes" do
      mock(File).read("some_file.yml") {"---\na: 5\n"}
      ye = YamlExtras.new("some_file.yml")
      ye.result.should == {"a" => 5}
      ye.result.should == {"a" => 5}
    end
  end

  describe :integrate_includes do
    it "should allow absolute paths" do
      fs_root = File.expand_path "/"
      fname = File.join(fs_root, "first.yml")

      first = "---\na: 1\nINCLUDE: #{fname}\n"
      yaml_body = "---\nb: 2\n"

      mock(File).read("first.yml") { first }
      mock(File).read(fname) { yaml_body }

      YamlExtras.new("first.yml").result.should == { "a" => 1, "b" => 2 }
    end

    it "should use paths relative to the parent file" do
      first = "---\nINCLUDE: second.yml\n"
      second = "---\na: 1\n"

      expected = { "a" => 1 }

      expected_second_path = File.join(
        File.dirname(File.expand_path("some_path/first.yml")),
        "second.yml")

      mock(File).read("some_path/first.yml") { first }
      mock(File).read(expected_second_path) { second }

      YamlExtras.new("some_path/first.yml").result.should == { "a" => 1 }
    end

    it "should be hash with INCLUDEs integrated" do
      other = "---\nb: 2\n"
      input = "---\na: 1\nINCLUDE: other.yml\n"
      expect = { "a" => 1, "b" => 2 }
      
      mock(File).read("some_file.yml") { input }
      mock(File).read(File.expand_path("other.yml")) { other }

      YamlExtras.new("some_file.yml").integrate_includes.should == expect
    end

    it "should handle nested INCLUDEs" do
      first  = "---\na: 1\nINCLUDE: second.yml\n"
      second = "---\nb: 2\nINCLUDE: third.yml\n"
      third  = "---\nc: 3\n"
 
      expect = { "a" => 1, "b" => 2, "c" => 3 }

      mock(File).read("first.yml")  { first  }
      mock(File).read(File.expand_path("second.yml")) { second }
      mock(File).read(File.expand_path("third.yml"))  { third  }

      YamlExtras.new("first.yml").integrate_includes.should == expect
    end

    it "should allow multiple inclusion of the same file" do
      first  = ["---",
                "  a:",
                "    INCLUDE: second.yml",
                "  b:",
                "    INCLUDE: second.yml"].join("\n")
      second = "---\nc: 100\n"

      expect = { "a" => { "c" => 100 }, "b" => { "c" => 100 } }

      mock(File).read("first.yml") { first }
      mock(File).read(File.expand_path("second.yml")) { second }
      mock(File).read(File.expand_path("second.yml")) { second }

      YamlExtras.new("first.yml").integrate_includes.should == expect
    end

    it "should reject direct cyclic INCLUDEs" do
      input = "---\na: 1\nINCLUDE: some_file.yml\n"

      mock(File).read("some_file.yml") { input }

      lambda {
          YamlExtras.new("some_file.yml").integrate_includes
        }.should raise_error(CyclicYamlExtrasInclude)
    end
    
    it "should reject indirect cyclic INCLUDEs" do
      first  = "---\na: 1\nINCLUDE: second.yml\n"
      second = "---\nb: 2\nINCLUDE: first.yml\n"

      mock(File).read("first.yml") { first }
      mock(File).read(File.expand_path("second.yml")) { second }

      lambda {
          YamlExtras.new("first.yml").integrate_includes
        }.should raise_error(CyclicYamlExtrasInclude)
    end
  end
end
