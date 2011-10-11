class ObjectPathing
  def self.apply_path(o, p)
    p.inject(o) do |obj, key|
      obj[key]
    end
  end

  def self.find_paths_to_keys(keys, obj)
    paths = []

    go = lambda do |p, o|
      case o
        when Hash
          o.each_pair do |k, v|
            p_ = p.clone << k
            if keys.include?(k)
              paths << p_
            end
            go.call(p_, v)
          end
        when Array
          o.each_index do |i|
            p_ = p.clone << i
            go.call(p_, o[i])
          end
      end
    end

    go.call([], obj)

    paths
  end
end

class CyclicYamlExtrasInclude < Exception
end

class YamlExtras
  attr_accessor :result, :includes_integrated, :file_name

  def initialize(file_name, parents = [])
    @file_name = file_name
    @parents = parents
    @included = []
  end

  def original
    @original ||= YAML.load(File.read(@file_name))
  end

  def integrate_includes
    raise CyclicYamlExtrasInclude if @parents.include? @file_name

    unless @includes_integrated
      @includes_integrated = original.clone

      ObjectPathing.find_paths_to_keys(["INCLUDE"], @includes_integrated).each do |l|
        # path except last key which should be the 'INCLUDE' key
        target_obj_path = l[0...-1] 

        # the object containing the 'INCLUDE' key
        target_obj = ObjectPathing.apply_path(@includes_integrated, target_obj_path)

        # the path to the file to be included
        file_path = ObjectPathing.apply_path(@includes_integrated, l)

        # remove the INCLUDE key. it's not supposed to be in the final result
        target_obj.delete "INCLUDE"

        # recursively apply YamlExtras in order to deal with any includes that
        # may exist in the included file.
        inc_data = YamlExtras.new(file_path, @parents.clone << @file_name).integrate_includes

        # loop over the fields of the included data and stash them in the
        # object which originally contained the 'INCLUDE' key
        inc_data.each_pair do |k, v|
          target_obj[k] = v
        end
      end
    end

    @includes_integrated
  end
end
