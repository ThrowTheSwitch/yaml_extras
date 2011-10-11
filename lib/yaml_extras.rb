class ObjectPathing
  def self.apply_path(o, p)
    p.inject(o) do |obj, key|
      obj[key]
    end
  end

  def self.find_path_to_key(key, obj)
    go = lambda do |c, k, o|
      if o.respond_to?(:has_key?) and o.has_key?(k)
        c << k
      else
        case o
          when Hash
            unless o.empty?
              o.each_pair do |j, v|
                r = go.call(c.clone << j, k, v)
                return r unless r.nil?
              end
              return nil
            end
          when Array
            unless o.empty?
              o.each_index do |i|
                r = go.call(c.clone << i, k, o[i])
                return r unless r.nil?
              end
              return nil
            end
          else 
            nil
        end
      end
    end

    go.call([], key, obj)
  end
end

class YamlExtras
  attr_accessor :result, :original

  def initialize(file_name)
    @original = YAML.load(File.read(file_name))
    @result = @original
  end
end
