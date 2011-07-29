# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def calculate_bar(dyno,time_begin,time_end,dyno_height,hour_width)
    bar_height = dyno * dyno_height
    bar_width = (((time_end - time_begin) * hour_width) / (60 * 60)).to_i

    return bar_width, bar_height
  end
end
