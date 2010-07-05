require 'test_helper'

class CalendarHelperTest < ActionView::TestCase
  include CalendarHelper

  def setup
    @events = [
      Event.new(3, 'Jimmy Page', DateTime.civil(2008, 12, 26, 1)), # In case is an hour of that day
      Event.new(4, 'Robert Plant', Date.civil(2008, 12, 26))
    ]
    @events2 = [
      Event.new(3, 'Jimmy Page', [DateTime.civil(2008, 12, 26, 1), DateTime.civil(2008, 12, 27, 1)]), # In case is an hour of that day
      Event.new(4, 'Robert Plant', Date.civil(2008, 12, 26))
    ]
  end

  should 'raise error if called without array' do
    assert_raises(ArgumentError) { calendar_for('a') {|t|} }
  end
  
  context 'Calendar days' do
    should 'return objects_for_days with day and empty array' do
      calendar = CalendarHelper::Calendar.new :year=> 2008, :month => 12
      objects_for_days = (Date.civil(2008, 11, 30)..Date.civil(2009, 1, 3)).map { |day| [day, []] }
      assert_equal objects_for_days, calendar.objects_for_days([], &:date)
    end
    
    should 'return objects_for_days with days and events' do
      calendar         = CalendarHelper::Calendar.new :year => 2008, :month => 12
      objects_for_days = (Date.civil(2008, 11, 30)..Date.civil(2009, 1, 3)).map do |day|
        [day, Date.civil(2008, 12, 26) == day ? @events : []]
      end
      assert_equal objects_for_days, calendar.objects_for_days(@events, &:date)
    end
    
    should 'return objects_for_days with days and events when event has multiple dates' do
      calendar         = CalendarHelper::Calendar.new :year => 2008, :month => 12
      objects_for_days = (Date.civil(2008, 11, 30)..Date.civil(2009, 1, 3)).map do |day|
        object =
        case day
        when DateTime.civil(2008, 12, 26, 1) then @events2
        when DateTime.civil(2008, 12, 27, 1) then [@events2.first]
        else [] end
        [day, object]
      end
      assert_equal objects_for_days, calendar.objects_for_days(@events2, &:date)
    end
    
    
    should 'return objects_for_days with days accepting a block' do
      calendar         = CalendarHelper::Calendar.new :year=> 2008, :month => 12
      objects_for_days = (Date.civil(2008, 11, 30)..Date.civil(2009, 1, 3)).map do |day|
        [day, Date.civil(2008, 12, 26) == day ? @events : []]
      end
      assert_equal objects_for_days, calendar.objects_for_days(@events){ |o| o.date  }
    end

    should 'map day range for calendar' do
      calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12)
      assert_equal (Date.civil(2008, 11, 30)..Date.civil(2009, 1, 3)).map, calendar.days
    end

    should 'map day range starting from monday when passed first_weekday' do
      calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12, :first_weekday => 1)
      assert_equal (Date.civil(2008, 12, 1)..Date.civil(2009, 1, 4)).map, calendar.days
    end

    should 'set first day to previous sunday' do
      calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12)
      assert_equal Date.civil(2008, 11, 30), calendar.first_day
    end

    should 'set last day to following sunday' do
      calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12)
      assert_equal Date.civil(2009, 1, 3), calendar.last_day
    end
    
    should 'start range from previous monday when first_weekday is one' do
      calendar = CalendarHelper::Calendar.new(:year=> 2008, :month => 12, :first_weekday => 1)
      assert_equal Date.civil(2009, 1, 4), calendar.last_day
    end
  end
  
  context 'ERB Rendering' do
    should 'render table for calendar' do
      erb = <<-ERB
         <% calendar_for @events, :html => { :id => 'id', :style => 'style', :class => 'class'} do |t| %>
         <% end %>
       ERB
       assert_dom_equal %(<table id="id" style="style" class="class"></table>), render(:inline => erb)
    end
    
    should 'render trs and tds with empty array' do
      erb = <<-ERB
        <% calendar_for [], :year=> 2008, :month => 12 do |c| %>
          <% c.day do |day, events| %>
          <% end %>
        <% end %>
      ERB
    
      html = <<-HTML 
      <table>
        <tbody>
          <tr><td class="notmonth weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>
          <tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>
          <tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>
          <tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>
          <tr><td class="weekend"></td><td></td><td></td><td></td><td class="notmonth"></td><td class="notmonth"></td><td class="notmonth weekend"></td></tr>
        </tbody>
      </table>
      HTML
      assert_dom_equal html, render(:inline => erb)
    end
   
    should 'output day numbers' do
      erb = <<-ERB
        <% calendar_for @events, :year=> 2008, :month => 12 do |c| %>
          <% c.day do |day, events| %>
            <%= day.day %>
          <% end %>
        <% end %>
      ERB
  
      html = <<-HTML
      <table>
        <tbody>
          <tr><td class="notmonth weekend">30</td><td>1</td><td>2</td><td>3</td><td>4</td><td>5</td><td class="weekend">6</td></tr>
          <tr><td class="weekend">7</td><td>8</td><td>9</td><td>10</td><td>11</td><td>12</td><td class="weekend">13</td></tr>
          <tr><td class="weekend">14</td><td>15</td><td>16</td><td>17</td><td>18</td><td>19</td><td class="weekend">20</td></tr>
          <tr><td class="weekend">21</td><td>22</td><td>23</td><td>24</td><td>25</td><td>26</td><td class="weekend">27</td></tr>
          <tr><td class="weekend">28</td><td>29</td><td>30</td><td>31</td><td class="notmonth">1</td><td class="notmonth">2</td><td class="notmonth weekend">3</td></tr>
        </tbody>
      </table>
      HTML

      assert_dom_equal html, render(:inline => erb)
    end
  
    should 'render events' do
      erb = <<-ERB
        <% calendar_for @events, :year=> 2008, :month => 12 do |c| %>
          <% c.day do |day, events| %>
            <%= events.map(&:id).join(',') %>
          <% end %>
        <% end %>
      ERB

      html = <<-HTML 
      <table>
        <tbody>
          <tr><td class="notmonth weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>
          <tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>
          <tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td></td><td class="weekend"></td></tr>
          <tr><td class="weekend"></td><td></td><td></td><td></td><td></td><td>3,4</td><td class="weekend"></td></tr>
          <tr><td class="weekend"></td><td></td><td></td><td></td><td class="notmonth"></td><td class="notmonth"></td><td class="notmonth weekend"></td></tr>
        </tbody>
      </table>
      HTML
      assert_dom_equal html, render(:inline => erb)
    end

    should 'render id attribute for using pattern' do
      erb = <<-ERB
        <% calendar_for @events, :year=> 2008, :month => 12, :today => Date.civil(2008, 12, 15) do |c| %>
          <% c.day :id => 'day_%d' do |day, events| %>
            <%= events.map(&:id).join(',') %>
          <% end %>
        <% end %>
      ERB

      html = <<-HTML
        <table>
          <tbody>
            <tr><td class="notmonth weekend" id="day_30"></td><td id="day_01"></td><td id="day_02"></td><td id="day_03"></td><td id="day_04"></td><td id="day_05"></td><td class="weekend" id="day_06"></td></tr>
            <tr><td class="weekend" id="day_07"></td><td id="day_08"></td><td id="day_09"></td><td id="day_10"></td><td id="day_11"></td><td id="day_12"></td><td class="weekend" id="day_13"></td></tr>
            <tr><td class="weekend" id="day_14"></td><td class="today"id="day_15"></td><td id="day_16"></td><td id="day_17"></td><td id="day_18"></td><td id="day_19"></td><td class="weekend" id="day_20"></td></tr>
            <tr><td class="weekend" id="day_21"></td><td id="day_22"></td><td id="day_23"></td><td id="day_24"></td><td id="day_25"></td><td id="day_26">3,4</td><td class="weekend" id="day_27"></td></tr>
            <tr><td class="weekend" id="day_28"></td><td id="day_29"></td><td id="day_30"></td><td id="day_31"></td><td class="notmonth" id="day_01"></td><td class="notmonth" id="day_02"></td><td class="notmonth weekend" id="day_03"></td></tr>
          </tbody>
        </table>
      HTML
      assert_dom_equal html, render(:inline => erb)
    end
  
  end
end


