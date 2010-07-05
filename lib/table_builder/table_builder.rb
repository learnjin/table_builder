module TableHelper

  def table_for objects = [], options = {}
    html_options = options.delete(:html)
    builder      = options.delete(:builder) || TableBuilder
    concat content_tag(:table, html_options) { yield builder.new(objects, self, options) }
  end

  class TableBuilder
    def initialize objects, template, options
      raise ArgumentError, "TableBuilder expects an Array or ActiveRecord::NamedScope::Scope but found a #{objects.class}" unless Array === objects or ActiveRecord::NamedScope::Scope === objects
      @objects, @template, @options = objects, template, options
    end
    
    def body options = {}
      concat content_tag(:tbody, @objects.map{ |o| capture {yield o} }, options)
    end
    
    def body_r options = {}
      concat content_tag(:tbody, @objects.map{ |o| r capture {yield o}, options })
    end
    
    def head *args, &block
      return tag(:thead, *args, &block) if block_given?
      options = args.extract_options!
      content = (args.size == 1 ? args.first : args).map{|c|"<th>#{c}</th>"}
      content_tag :thead, r(content), options
    end

    def head_r *args, &block
      head { tag :tr, *args, &block }
    end
    
    def r *args, &block
      tag :tr, *args, &block
    end

    def h *args, &block
      tag :th, *args, &block
    end

    def d *args, &block
      tag :td, *args, &block
    end

    private
    def tag tag, *args, &block
      options = args.extract_options!
      return concat content_tag(tag, capture(&block), options) if block_given?
      content_tag tag, args, options
    end
    
    def concat str
      @template.concat str
    end
    
    def capture &block
      @template.capture &block
    end

    def content_tag tag, content, options = {}
      @template.content_tag(tag, content, options)
    end
  end
end