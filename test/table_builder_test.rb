require 'test_helper'

class TableBuilderTest < ActionView::TestCase
  include TableHelper
  attr_accessor :output_buffer  
  
  def setup
    @drummers = [
      Drummer.new(1, 'John "Stumpy" Pepys'),
      Drummer.new(2, 'Eric "Stumpy Joe" Childs'),
    ]
  end
  
  should 'raise argument error with out array' do
    assert_raises(ArgumentError) { table_for('a') {|t|} }
  end
  
  context 'ERB rendering' do
    should 'output table tag' do
      erb = <<-ERB
        <% table_for [], :html => { :id => 'id', :style => 'style', :class => 'class'} do |t| %>
        <% end %>
      ERB
      assert_dom_equal  %(<table id="id" style="style" class="class"></table>), render(:inline => erb)
    end
        
    should 'output table tag with content' do
      erb = <<-ERB
        <% table_for [] do |t| %>
          <tr></tr>
          <tr></tr>
        <% end %>
      ERB
      assert_dom_equal  %(<table><tr></tr><tr></tr></table>), render(:inline => erb)
    end
    
    should 'output table tag with content and erb tags' do
      erb = <<-ERB
        <% table_for [] do |t| %>
          <%= '<tr></tr>' %>
          <tr></tr>
          <%= '<tr></tr>' %>
        <% end %>
      ERB
      assert_dom_equal  %(<table><tr></tr><tr></tr><tr></tr></table>), render(:inline => erb)
    end
    
    should 'output table head passing an array' do
      erb = <<-ERB
      <% table_for [] do |t| %>
        <%= t.head %w(a b c), :class => 'head' %>
      <% end %>
      ERB
      assert_dom_equal %(<table><thead class="head"><tr><th>a</th><th>b</th><th>c</th></tr></thead></table>), render(:inline => erb)
    end
      
    should 'output table head' do
      erb = <<-ERB
      <% table_for [] do |t| %>
        <% t.head(:class => 'head') do %>
        <% end %>
      <% end %>
      ERB
      assert_dom_equal %(<table><thead class="head"></thead></table>), render(:inline => erb)
    end
        
    should 'output table head with content' do
      erb = <<-ERB
      <% table_for [] do |t| %>
        <% t.head do %>
            <%= '<th></th>' %>
            <th></th>
            <%= '<th></th>' %>
        <% end %>
      <% end %>
      ERB
      assert_dom_equal %(<table><thead><th></th><th></th><th></th></thead></table>), render(:inline => erb)
    end

    should 'output table header inside head' do
      erb = <<-ERB
      <% table_for [] do |t| %>
        <% t.head do %>
            <%= t.h 'Id' %>
            <th></th>
            <%= t.h 'Name' %>
        <% end %>
      <% end %>
      ERB
      assert_dom_equal %(<table><thead><th>Id</th><th></th><th>Name</th></thead></table>), render(:inline => erb)
    end

    should 'output table header with block inside head' do
      erb = <<-ERB
      <% table_for [] do |t| %>
        <% t.head do %>
            <%- t.h do -%>
              <%= 'I' %>d
            <%- end -%>
            <th></th>
            <%= t.h 'Name' %>
        <% end %>
      <% end %>
      ERB
      assert_dom_equal %(<table><thead><th>Id</th><th></th><th>Name</th></thead></table>), render(:inline => erb)
    end

    should 'output head row with block' do
      erb = <<-ERB 
      <% table_for [] do |t| %>
        <% t.head_r :class => 'head' do %>
          <%= t.h('a') %>
          <th>b</th>
          <% t.h do %>
            c
          <% end %>
        <% end %>
      <% end %>
      ERB
      assert_dom_equal "<table><thead><tr class='head'><th>a</th><th>b</th><th>c</th></tr></thead></table>", render(:inline => erb)
    end
    
    should 'output tbody' do
      erb = <<-ERB 
      <% table_for @drummers do |t| %>
        <% t.head_r do %>
          <th>a</th><th>b</th><th>c</th>
        <% end %>
        <% t.body :class => 'body' do %>
        <% end %>
      <% end %>
      ERB
      assert_dom_equal "<table><thead><tr><th>a</th><th>b</th><th>c</th></tr></thead><tbody class='body'></tbody></table>", render(:inline => erb)
    end

    should 'output tbody with row and content' do
      erb = <<-ERB 
      <% table_for @drummers do |t| %>
        <% t.head_r do %>
          <th>id</th><th>name</th>
        <% end %>
        <% t.body do |d| %>
          <% t.r do %>
            <%= t.d d.id %>
            <%= t.d d.name %>
          <% end %>
        <% end %>
      <% end %>
      ERB
  
      html = <<-HTML
      <table>
        <thead>
          <tr><th>id</th><th>name</th></tr>
        </thead>
        <tbody>
          <tr><td>#{ @drummers.first.id }</td><td>#{ @drummers.first.name }</td></tr>
          <tr><td>#{ @drummers.last.id }</td><td>#{ @drummers.last.name }</td></tr>
        </tbody>
      </table>
      HTML
  
      assert_dom_equal html, render(:inline => erb)
    end    
    
    should 'output body rows' do
      erb = <<-ERB 
      <% table_for @drummers do |t| %>
        <% t.head_r do %>
          <th>id</th><th>name</th>
        <% end %>
        <% t.body_r do |e| %>
          <%= t.d e.id %>
          <%= t.d e.name %>
        <% end %>
      <% end %>
      ERB
      
      html = <<-HTML
      <table>
        <thead>
          <tr><th>id</th><th>name</th></tr>
        </thead>
        <tbody>
          <tr><td>#{ @drummers.first.id }</td><td>#{ @drummers.first.name }</td></tr>
          <tr><td>#{ @drummers.last.id }</td><td>#{ @drummers.last.name }</td></tr>
        </tbody>
      </table>
      HTML
      
      assert_dom_equal html, render(:inline => erb)
    end
    
    should 'output td with block and options' do
      erb = <<-ERB 
      <% table_for @drummers do |t| %>
        <% t.head_r do %>
          <th>id</th><th>name</th>
        <% end %>
        <% t.body_r do |e| %>
          <% t.d :class => 'id' do %>
            <%= e.id %>
          <% end %>
          <%= t.d e.name %>
        <% end %>
      <% end %>
      ERB
      
      html = <<-HTML
      <table>
        <thead>
          <tr><th>id</th><th>name</th></tr>
        </thead>
        <tbody>
          <tr><td class="id">#{ @drummers.first.id }</td><td>#{ @drummers.first.name }</td></tr>
          <tr><td class="id">#{ @drummers.last.id }</td><td>#{ @drummers.last.name }</td></tr>
        </tbody>
      </table>
      HTML
      
      assert_dom_equal html, render(:inline => erb)
    end
  end

end

