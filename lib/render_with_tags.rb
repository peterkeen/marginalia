require 'date'

class RenderWithTags < Redcarpet::Render::HTML

  def preprocess(full_document)
    full_document.gsub!(/(\s)#([a-zA-Z]\w+)/) do |match|
      "#{$1}[##{$2}](/tags/#{$2})"
    end

    full_document.gsub!(/(\s)#(\d+)/) do |match|
      "#{$1}[##{$2}](/notes/#{$2})"
    end

    current_date = nil
    full_document.gsub!(/@(\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d)/) do |match|
      date = DateTime.parse($1).to_time.in_time_zone('Pacific Time (US & Canada)')
      "* * *\n**#{date.strftime('%Y %b %d %l:%M %P')}**\n\n" 
    end

    @process_burndown = full_document.match(/{{{burndown (\d+)}}}/)

    full_document
  end

  def paragraph(text)
    if @process_burndown
      parse_story(text)
      parse_status(text)
    end
    "<p>#{text}</p>"
  end

  def header(text, header_level)
    if @process_burndown
      parse_day(text)
    end
    "<h#{header_level}>#{text}</h#{header_level}>"
  end

  def parse_day(text)
    match = text.match(/^Day (\d+)/)
    if match
      p match
      @current_day = match[1].to_i
    end
  end

  def parse_story(text)
    match = text.match(/^Story \((.*)\): /)
    if match
      p match
      if @stories.nil?
        @stories = {}
      end

      points = first_match(text, /Points: (\d+)/, 0).to_i
      hours = first_match(text, /Hours: (\d+)/, 0).to_i
      
      @stories[match[1]] = {
        :points => points,
        :hours => hours
      }
    end
  end

  def first_match(text, regex, default)
    if match = text.match(regex)
      return match[1]
    else
      return default
    end
  end

  def parse_status(text)
    match = text.match(/^Status \((.*)\): /)
    if match
      p match
      story_id = match[1]
      if not @stories.has_key? story_id
        puts "can't find story #{story_id}"
        return
      end

      hours_yesterday = first_match(text, /Yesterday: (\d+)/, 0).to_i
      hours_left = first_match(text, /Left: (\d+)/, 0).to_i
      done = first_match(text, /Done: (\w+)/, false)
      
      @stories[story_id]['days'] ||= {}
      @stories[story_id]['days'][@current_day] = {:yesterday => hours_yesterday, :left => hours_left, :done => done}
    end
  end

  def postprocess(full_document)
    if @process_burndown
      full_document.gsub!(/{{{burndown \d+}}}/) do |match|
        burndown_chart
      end
    end

    full_document
  end

  def burndown_chart
    num_days = @process_burndown[1].to_i

    points_by_day = []
    hours_by_day = []

    @stories.each do |story, info|
      points = []
      hours = []

      if info.has_key? 'days'
        done_day = @process_burndown[1].to_i

        info["days"].each do |day, day_info|
          if day_info[:done]
            done_day = day.to_i
          end

          if day_info[:left]
            hours[day] = day_info[:left]
          end
        end

        (0..(done_day - 1)).each do |day|
          points[day] = info[:points]
        end

        (done_day .. (num_days - 1)).each do |day|
          points[day] = 0
        end
      else
        (0..(num_days - 1)).each do |day|
          points[day] = info[:points]
        end
      end

      (0..(num_days - 1)).each do |day|
        hours_by_day[day] ||= 0
        if not hours[day].nil?
          hours_by_day[day] += hours[day]
        elsif day < done_day
          hours_by_day[day] += info[:hours]
        end
      end

      points.each_index do |i|
        points_by_day[i] ||= 0
        points_by_day[i] += points[i]
      end

    end

    rows = []
    points_by_day.each_index do |i|
      if i == 0
        straight = points_by_day[i]
      elsif i == points_by_day.length - 1
        straight = 0
      else
        straight = nil
      end
      rows[i] = [i + 1, points_by_day[i], hours_by_day[i], straight]
    end

    return <<HERE
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('number', 'Day');
        data.addColumn('number', 'Points');
        data.addColumn('number', 'Hours Left');
        data.addColumn('number', 'Straight Line');
        data.addRows(#{rows.to_json});

        var options = {
          title: 'Burndown Chart',
          interpolateNulls: true,
          series: {
            1:{
              targetAxisIndex: 1
            }
          },
          vAxes: {
            0:{
              maxValue: #{rows[0][1]},
              viewWindowMode: 'maximized'
            },
            1:{
              maxValue: #{rows[0][2]},
              viewWindowMode: 'maximized'
            }
          }
        };

        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
    <div id="chart_div" style="width: 800px; height: 500px;"></div>
HERE
  end
end
