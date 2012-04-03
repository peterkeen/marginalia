class Burndown

  def preprocess(full_document)
    @process = full_document.match(/{{{burndown (\d+)}}}/)
  end

  def header(text)
    if @process
      parse_day(text)
    end
  end

  def paragraph(text)
    if @process
      parse_story(text)
      parse_status(text)
    end
  end

  def postprocess(full_document)
    if @process
      full_document.gsub!(/{{{burndown \d+}}}/) do |match|
        burndown_chart
      end
    end

    full_document
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

  def burndown_chart
    num_days = @process[1].to_i

    points_by_day = []
    hours_by_day = []

    done_by_day = []

    p @stories

    @stories.each do |story, info|
      current_points = info[:points]
      current_hours = info[:hours]

      points = []
      hours = []
      done = false

      (0..(num_days - 1)).each do |day|
        if info.has_key?('days') && info['days'].has_key?(day)
          puts "#{day}: #{info['days'][day][:left]}"
          if done || info['days'][day][:done]
            done = true
            done_by_day[day] ||= 0
            done_by_day[day] += 1
            current_points = 0
            current_hours = 0
          else
            current_hours = info['days'][day][:left] 
          end
        end

        points[day] = current_points
        hours[day] = current_hours
      end

      p points
      p hours

      points.each_index do |i|
        points_by_day[i] ||= 0
        points_by_day[i] += points[i]

        hours_by_day[i] ||= 0
        hours_by_day[i] += hours[i] || 0
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
      rows[i] = [(i + 1).to_s, points_by_day[i], hours_by_day[i], straight, done_by_day[i] || 0]
    end

    return <<HERE
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Day');
        data.addColumn('number', 'Points');
        data.addColumn('number', 'Hours Left');
        data.addColumn('number', 'Straight Line');
        data.addColumn('number', 'Stories Done');
        data.addRows(#{rows.to_json});

        var options = {
          title: 'Burndown Chart',
          interpolateNulls: true,
          seriesType: "line",
          series: {
            1:{
              targetAxisIndex: 1
            },
            3:{
              type: 'bars'
            }
          },
          vAxes: {
            0:{
              title: "Points",
              maxValue: #{rows[0][1]},
              minValue: 0,
              viewWindowMode: 'maximized'
            },
            1:{
              title: "Hours",
              maxValue: #{rows[0][2]},
              minValue: 0,
              viewWindowMode: 'maximized'
            }
          }
        };

        var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
    <div id="chart_div" style="width: 800px; height: 500px;"></div>
HERE
  end

end
