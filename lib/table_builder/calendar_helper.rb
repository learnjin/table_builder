module CalendarHelper

  def calendar_for objects, options = {}
    html_options = options.delete(:html)
    builder      = options.delete(:builder)  || CalendarBuilder
    calendar     = options.delete(:calendar) || Calendar
    concat content_tag(:table, html_options){ yield builder.new(objects || [], self, calendar, options) }
  end

  class CalendarBuilder < TableHelper::TableBuilder
    def initialize objects, template, calendar, options
      @calendar = calendar.new(options)
      @today    = options[:today] || Time.now
      super objects, template, options
    end

    def day options = {}
      raise ArgumentError, "Missing block" unless block_given?
      day_method = options.delete(:day_method) || :date
      id_pattern = options.delete(:id)
      
      tag(:tbody) do
        output = ''
        @calendar.objects_for_days(@objects, &day_method).each_slice(7) do |week|
          output = r do
            week.map do |day, objects|
              d capture{yield day, objects}, td_options(day, objects, id_pattern)
            end
          end
        end
        output
      end
      
    end
  
    def td_options day, objects, id_pattern
      options = {}
      css     = []
      css << 'notmonth' if day.month != @calendar.month
      css << 'today'    if @today == day
      css << 'weekend'  if day.wday == 0 or day.wday == 6
      # css << 'empty'    if objects.empty?

      options[:class] = css.join(' ')
      options[:id]    = day.strftime(id_pattern) if id_pattern
      
      options.delete_if{ |k,v| v.blank? }
      options
    end
    
  end

  class Calendar
    attr_reader :month, :first_weekday, :last_weekday, :first_day, :last_day
    def initialize options = {}
      @year          = options[:year]  || Time.now.year
      @month         = options[:month] || Time.now.month
      @first_weekday = (options[:first_weekday] || 0) % 7
      @last_weekday  = (@first_weekday + 6) % 7
      @first         = Date.civil @year, @month, 1
      @last          = Date.civil @year, @month, -1
      @first_day     = @first - (@first.wday - @first_weekday + 7) % 7
      @last_day      = @last + (@last_weekday - @last.wday + 7) % 7
    end
    
    def each_day &block
      (first_day..last_day).map &block
    end

    def objects_for_days objects
      grouped = {}
      objects.each do |obj|
        [*yield(obj)].each do |val|
          key = val.strftime("%Y-%m-%d")
          grouped.has_key?(key) ? grouped[key] << obj : grouped[key] = [obj]
        end
      end
            
      each_day { |day| [day, grouped[day.strftime("%Y-%m-%d")] || []] }
    end
    
    def days
      @days ||= each_day
    end
  end
end