module KaiTableHelper

  def make_table(rows=0, cols=0, options = {})

    objects = options[:for]||[]
    options[:rows] = rows
    options[:cols] = cols

    html_options = options.delete(:html)
    builder      = options.delete(:builder) || KaiTableBuilder
    concat content_tag(:table, html_options) { yield builder.new(objects, self, options) }
  end

  class KaiTableBuilder
    def initialize objects, template, options
      raise ArgumentError, "TableBuilder expects an Array or ActiveRecord::NamedScope::Scope but found a #{objects.class}" unless Array === objects or ActiveRecord::NamedScope::Scope === objects
      @objects, @template, @options = objects, template, options

      ## initialize row, column vectors
      @rows = options[:rows]
      @cols = options[:cols]

      @rv = options[:rv]||(1..@rows).map{|r| [r]*@cols}.flatten
      @cv = options[:cv]||(1..@cols).to_a*@rows
      @vv = Array.new(@cols*@rows, [])

      @td_options = lambda{}

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

    # creates tr/td tags with ERB block content
    def cell options = {}
      raise ArgumentError, "Missing block" unless block_given?

      mapper = options[:map]||lambda{|r,c,o| false}
      id_pattern = options.delete(:id)
      @td_options = options.delete(:td)||lambda{}

      return tag(:tbody){''} if @rows*@cols == 0

      @cv = (options[:cv].to_a*@rows).slice(0, @rows*@cols) if options[:cv]
      @rv = (options[:rv].to_a*@cols).slice(0, @rows*@cols).
        each_slice(@rows).to_a.transpose.flatten if options[:rv]

      # create the (2d) Cell-Matrix (the real content)
      # and map objects to cells according to mapper function
      @matrix = @rv.zip(@cv).map{|r,c| Cell.new(r,c, @objects.select{|o|
        mapper[r,c,o]}) }.each_slice(@cols).to_a

      if @colf
        adjust = @rowf ? ["<th></th>"] : []
        # add column captions
        head_r adjust + @matrix.transpose.map{|cells|
          content_tag('th',capture{@colf.call(cells)})}
      end

      tag(:tbody) do
        output = ''
        @matrix.each do |row|
          output = r do
            output = []
            # add row caption
            output += [d capture{@rowf.call(row)}] if @rowf
            # add cells of current row
            cell_values = row.map do |cell|
              d capture{yield cell.row, cell.col, cell.objects},
                @td_options.call(cell)
            end
            output += cell_values #.map{|cv| d cv }
          end
        end
        output
      end
    end

    # obsolete
    def td_options cell, id_pattern
      options = {}
      css     = []

      options[:class] = css.join(' ')
      options[:id]    = day.strftime(id_pattern) if id_pattern
      
      options.delete_if{ |k,v| v.blank? }
      options
    end

    def row_caption options = {}, &block
      raise ArgumentError, "Missing block" unless block_given?
      @rowf = block
    end

    def col_caption *args, &block
      raise ArgumentError, "Missing block" unless block_given?
      @colf = block
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

  class Cell < Struct.new(:row, :col, :objects); end

end
