require File.join(File.dirname(__FILE__), 'test_helper')

class WeeklyHelperTest < ActionView::TestCase
  include WeeklyHelper

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

  #should 'raise error if called without array' do
  #  assert_raises(ArgumentError) { weekly_calendar_for('a') {|t|} }
  #end

  context 'ERB rendering' do
    should 'create cells with row and dates' do

      erb=<<-ERB
    <% weekly_calendar :rv => [1,2], 
        :from => Date.civil(2010,7,10), 
        :today => Date.civil(2010,7,13) do |t|%>
      <% t.day do |r,day,events| %>
        <%= r %>,<%= day.strftime("%Y-%m-%d") %> 
      <% end %>
    <% end %>
      ERB

      html=<<-HTML
      <table>
      <tbody>
        <tr>  
          <td class="weekend">1,2010-07-10</td>
          <td class="weekend">1,2010-07-11</td>
          <td>1,2010-07-12</td>
          <td class="today">1,2010-07-13</td>
          <td>1,2010-07-14</td>
          <td>1,2010-07-15</td>
          <td>1,2010-07-16</td>
        </tr>
        <tr>  
          <td class="weekend">2,2010-07-10</td>
          <td class="weekend">2,2010-07-11</td>
          <td>2,2010-07-12</td>
          <td class="today">2,2010-07-13</td>
          <td>2,2010-07-14</td>
          <td>2,2010-07-15</td>
          <td>2,2010-07-16</td>
        </tr>
      </tbody>
      </table>
      HTML

      assert_dom_equal(html, render(:inline => erb))
    end
  end

end
