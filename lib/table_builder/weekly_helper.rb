module WeeklyHelper

  def weekly_calendar(options={})
    objects = options[:for]||[]
    #@rv = options[:rv]||[1]
    options[:rows] = options[:rv].size
    options[:cols] ||= 7

    html_options = options.delete(:html)
    builder      = options.delete(:builder) || WeeklyBuilder
    concat content_tag(:table, html_options) { yield builder.new(objects, self, options) }
  end

  class WeeklyBuilder < KaiTableHelper::KaiTableBuilder
    def initialize objects, template, options
      @today    = options[:today] || Time.now
      @from     = options[:from]  || @today 
      super objects, template, options
    end

    def day options = {}, &block
      #@cv = (@from..@from+6).to_a
      options[:td] = lambda{|x| td_options(x)}
      options[:rv] = @rv
      options[:cv] = @from..@from+6
      cell(options, &block)
    end

    def td_options cell
      options = {}
      css = []
      css << "weekend" if [0,6].include? cell.col.wday
      css << "today"   if cell.col == @today

      options[:class] = css.join(' ')
      options.delete_if{|k,v| v.blank?}
      options
    end
  
  end

  class Cell < Struct.new(:row,:col,:val)
  end

end
