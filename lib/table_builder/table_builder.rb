module TableHelper

  def table_for objects = [], options = {}
    raise ArgumentError, "Missing block" unless block_given?
    html_options = options.delete(:html)
    builder      = options.delete(:builder) || TableBuilder

    concat content_tag(:table, html_options){ yield builder.new(objects, self, options) }
  end

  class TableBuilder
    def initialize objects, template, options
      raise ArgumentError, "TableBuilder expects an Array but found a #{objects.inspect}" unless objects.is_a? Array
      @objects, @template, @options = objects, template, options
    end
    
    def body options = {}, &block
      raise ArgumentError, "Missing block" unless block_given?
      tbody { @objects.map(&block).join("\n") }
    end

    def body_r options = {}
      raise ArgumentError, "Missing block" unless block_given?
      tbody { @objects.map { |c| content_tag(:tr, capture{yield(c)}, options) }.join("\n") }
    end
    
    def head *args, &block
      return content_tag(:thead, capture(&block), args.extract_options!) if block_given?
      content_tag :thead, content_tag(:tr, args.map{|c|"<th>#{c}</th>"}.join )
    end
    
    def head_r options = {}, &block
      raise ArgumentError, "Missing block" unless block_given?
      head { r options, &block }
    end
    
    def r options = {}, &block
      raise ArgumentError, "Missing block" unless block_given?
      content_tag(:tr, capture(&block), options) 
    end

    def h *args, &block
      cell :th, *args, &block
    end

    def d *args, &block
      cell :td, *args, &block
    end

    private
    def cell tag, *args, &block
      options = args.extract_options!
      content = block_given? ? capture(&block) : args
      content_tag tag, content, options
    end
    
    def capture &block
      @template.capture &block
    end

    def content_tag tag, content, options = {}
      @template.content_tag tag, content, options
    end

    def tbody options = {}, &block
      content_tag :tbody, capture(&block), options
    end
  end
end