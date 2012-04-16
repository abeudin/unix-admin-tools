module ETC
  VERSION = '0.2.0'
  PASSWD_PATH = '/etc/passwd'
  GROUP_PATH = '/etc/group'
  DELIMS = %w(: ,) 

  class Passwd
    include Enumerable
    attr :entries
    attr :name_map
    attr :uid_map
    def initialize path = PASSWD_PATH
      @entries = [] 
      @name_map = {}
      @uid_map = {}
      open path do |f|
        f.each do |line|
          next if line[%r{^\s*#}o] or line[%r{^\s*$}o]
          entry = PasswdEntry.new line
          entries << entry 
          name_map[entry.name] = entry 
          uid_map[entry.uid.to_i] = entry 
        end
      end
    end

    def to_s; entries.map{|e| e.to_s}.join "\n"; end
    def inspect; entries.inspect; end

    def [] k
      k = k.to_s
      k =~ %r{^\s*\d+\s*$} ? uid_map[k.to_i] : name_map[k]
    end

    def each(&block); entries.each(&block); end

    def size; entries.size; end 

    class PasswdEntry
      include Enumerable
      FIELDS = Hash[
        :name      => 0,
        :passwd    => 1,
        :uid       => 2,
        :gid       => 3,
        :long_name => 4,
        :home      => 4,
        :shell     => 6,
      ]

      def method_missing(meth, *args, &block)
        idx = FIELDS[meth]
        raise NameError, meth.to_s  unless idx
        return fields[idx]
      end

      attr :fields
      def initialize arg 
        @fields = []
        case arg
          when String
            fields.push(*(arg.strip.split(DELIMS[0])))
          when Array
            fields.push(*arg)
          else
            raise ArgumentError, arg.class
        end
      end

      def to_s; fields.join DELIMS[0]; end
      def inspect; fields.inspect; end

      def each
        raise ArgumentError.new('NO BLOCK') unless block_given?
        FIELDS.map{|f,idx| yield f, fields[idx]}
      end
      alias map each

      def <=> other; fields <=> other.fields; end
    end
  end


  class Group
    include Enumerable
    attr :entries
    attr :name_map
    attr :gid_map
    def initialize path = GROUP_PATH
      @entries = [] 
      @name_map = {}
      @gid_map = {}
      open path do |f|
        f.each do |line|
          next if line[%r{^\s*#}o] or line[%r{^\s*$}o]
          entry = GroupEntry.new line
          entries << entry 
          name_map[entry.name] = entry
          gid_map[entry.gid.to_i] = entry
        end
      end
    end

    def to_s; entries.map{|e| e.to_s}.join "\n"; end
    def inspect; entries.inspect; end

    def [] k
      k = k.to_s
      k =~ %r{^\s*\d+\s*$} ? gid_map[k.to_i] : name_map[k]
    end

    def each(&block); entries.each(&block); end

    def size; entries.size; end 

    class GroupEntry
      include Enumerable
      FIELDS = Hash[
        :name      => 0,
        :passwd    => 1,
        :gid       => 2,
        :users     => 3,
      ]

      def method_missing(meth, *args, &block)
        idx = FIELDS[meth]
        raise NameError, meth.to_s  unless idx
        return fields[idx]
      end

      attr :fields
      def initialize arg 
        @fields = []
        case arg
          when String
            a = arg.strip.split DELIMS[0]
            if users = a[3]
              a[3] = users.strip.split DELIMS[1]
            end
            fields.push(*a)
          when Array
            raise ArgumentError, a[3].class unless not a[3] or a[3] and Array === a[3]
            fields.push(*arg)
          else
            raise ArgumentError, arg.class
        end
      end

      def to_s; fields.join DELIMS[0]; end
      def inspect; fields.inspect; end

      def each(&block)
        FIELDS.map{|f,idx| yield f, fields[idx]}
      end
      alias map each

      def <=> other; fields <=> other.fields; end
    end
  end

  # pre-construced objects.  sort of a singleton pattern
  PASSWD = Passwd.new
  GROUP = Group.new
end
