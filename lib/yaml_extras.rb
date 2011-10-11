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

class YamlExtras
  attr_accessor :result, :original

  def initialize(file_name)
    @original = YAML.load(File.read(file_name))
  end

  def integrate_includes
  end
end
