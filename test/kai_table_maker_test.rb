require File.join(File.dirname(__FILE__),'test_helper')

class KaiTableBuilderTest < ActionView::TestCase
  include KaiTableHelper
  attr_accessor :output_buffer  
  
  def setup
    @drummers = [
      Drummer.new(1, 'John "Stumpy" Pepys'),
      Drummer.new(2, 'Eric "Stumpy Joe" Childs'),
    ]
    @foos = [
      Foo.new(1, 'one', 1, 1),
      Foo.new(2, 'two',2,3),
      Foo.new(3, 'three', 2,3)
    ]
    @events = [
      Event.new(1, 'event2', Date.civil(2010,7,25)),
      Event.new(2, 'event1', Date.civil(2010,7,22))
    ]
  end
  
  #should 'raise argument error with out array' do
  #  assert_raises(ArgumentError) { table_for('a') {|t|} }
  #end
  
  context 'ERB rendering' do
    should 'output table tag' do
      erb = <<-ERB
        <% make_table(0,0,:html => { :id => 'id', :style => 'style', :class => 'class'}) do |t| %>
        <% end %>
      ERB
      assert_dom_equal  %(<table id="id" style="style" class="class"></table>), render(:inline => erb)
    end

    should 'output table tag with content' do
      erb = <<-ERB
        <% make_table do |t| %>
          <tr></tr>
          <tr></tr>
        <% end %>
      ERB
      assert_dom_equal  %(<table><tr></tr><tr></tr></table>), render(:inline => erb)
    end

    should 'output table tag with content and erb tags' do
      erb = <<-ERB
        <% make_table do |t| %>
          <%= '<tr></tr>' %>
          <tr></tr>
          <%= '<tr></tr>' %>
        <% end %>
      ERB
      assert_dom_equal  %(<table><tr></tr><tr></tr><tr></tr></table>), render(:inline => erb)
    end

    should 'output table with specified dimensions' do
      erb = <<-ERB
        <% make_table(2,3) do |t| %>
         <% t.cell do %> 
         <% end %>
        <% end %>
      ERB
      assert_dom_equal %(<table><tbody><tr><td></td><td></td><td></td></tr>
                         <tr><td></td><td></td><td></td></tr></tbody></table>), render(:inline => erb)
    end


    should 'assign row and column values ids to every cell' do
      erb = <<-ERB
        <% make_table(2,3) do |t| %>
         <% t.cell do |row, col, objects|  %> 
           <%= row %><%= col %>
         <% end %>
        <% end %>
      ERB
      assert_dom_equal %(<table><tbody><tr><td>11</td><td>12</td><td>13</td></tr>
                         <tr><td>21</td><td>22</td><td>23</td></tr></tbody></table>), render(:inline => erb)
    end

  
    should 'map objects to cells according to the given mapper function' do
      erb = <<-ERB
        <% make_table(2,3, :for => @foos) do |t| %>
         <% t.cell :map => lambda{|r,c,o| o.row == r and o.col == c} do |row, col, objects|  %> 
           <%= objects.map(&:name).join(",") %> 
         <% end %>
        <% end %>
      ERB
      assert_dom_equal %(<table><tbody><tr><td>one</td><td></td><td></td></tr>
                         <tr><td></td><td></td><td>two,three</td></tr></tbody></table>), render(:inline => erb)
    end


    should 'take row and column vectors and extend them if necessary' do
      erb = <<-ERB
        <% make_table(2,3) do |t| %>
         <% t.cell :rv => 1..6, :cv => 'a'..'f' do |row, col, objects|  %> 
           <%= row %><%= col %>
         <% end %>
        <% end %>
      ERB
      assert_dom_equal %(<table><tbody>
                        <tr><td>1a</td><td>3b</td><td>5c</td></tr>
                        <tr><td>2d</td><td>4e</td><td>6f</td></tr>
                        </tbody></table>), render(:inline => erb)
    end


    should 'create row captions' do
      erb = <<-ERB
        <% make_table(2,6) do |t| %>

         <% t.row_caption  do |rowcells| %>
           <%= rowcells.first.row %>(<%= rowcells.count %>)
         <% end %>

         <% t.cell do %> 

         <% end %>

        <% end %>
      ERB
      assert_dom_equal %(<table><tbody>
                        <tr><td>1(6)</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
                        <tr><td>2(6)</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
                        </tbody></table>), render(:inline => erb)
    end

    should 'perform row calculations' do
      erb = <<-ERB
        <% make_table(2,2) do |t| %>
          <% t.row_caption do |rowcells| %>
            SUM=<%= rowcells.inject(0){|s,e| s+e.col }  %>
          <% end %>
          <% t.cell(:cv => 1..4) do |r, c, obj| %>
            <%= c %> 
          <% end %>
        <% end %>
      ERB
      
      assert_dom_equal %(<table><tbody>
                        <tr><td>SUM=3</td><td>1</td><td>2</td></tr>
                        <tr><td>SUM=7</td><td>3</td><td>4</td></tr>
                        </tbody></table>), render(:inline => erb)
    end

    should 'create col captions' do
      erb=<<-ERB
        <% make_table(2,3) do |t| %>

         <% t.col_caption  do |cells| %>
           <%= cells.map(&:row).inject(0){|s,e| s+e }%>
         <% end %>

         <% t.cell do |r,c,objs| %> 
          <%= r %>
         <% end %>

        <% end %>
     ERB
      assert_dom_equal %(<table>
                         <thead>
                           <tr><th>3</th><th>3</th><th>3</th></tr>
                         </thead>
                         <tbody>
                          <tr><td>1</td><td>1</td><td>1</td></tr>
                          <tr><td>2</td><td>2</td><td>2</td></tr>
                        </tbody>
                        </table>), render(:inline => erb)

    end


    should 'create col captions from 2nd column on if there is row caption as well' do
      erb=<<-ERB
        <% make_table(1,2) do |t| %>

         <% t.col_caption  do |cells| %>
           <%= cells.first.col %>
         <% end %>

         <% t.row_caption  do |cells| %>
         <% end %>

         <% t.cell do |r,c,objs| %> 
         <% end %>

        <% end %>
     ERB
      assert_dom_equal %(<table>
                         <thead>
                           <tr><th></th><th>1</th><th>2</th></tr>
                         </thead>
                         <tbody>
                          <tr><td></td><td></td><td></td></tr>
                        </tbody>
                        </table>), render(:inline => erb)

    end

    should 'deal with nil sized tables' do
      erb=<<-ERB
        <% @from = Date.civil(2010, 7, 15) %>
        <% make_table 0,0 do |t|%>
          <% t.cell :rv => 1..2, :cv => @from..@from+6 do |r,c,events|%> 
          <% end %>
        <% end %>
      ERB

      assert_dom_equal(
        %(<table>
          <tbody>
          </tbody>
          </table>), render(:inline => erb) )
    end

    should 'take a td option method as parameter' do
      erb=<<-ERB
      <% make_table 1,2 do|t| %>
        <% t.cell :td => lambda{|c| {:class => c.col}} do %>
        <% end %>
      <% end %>
      ERB

      html=<<-HTML
      <table>
      <tbody>
        <tr><td class="1"></td><td class="2"></td></tr>
      </tbody>
      </table>
      HTML

      assert_dom_equal(html, render(:inline => erb))
    end

        
  end # context

end

