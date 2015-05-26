# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# translated algorithm from http://mindmeat.blogspot.fr/2008/07/java-image-comparison.html
require_relative "imagecompare_helper"

class LogStash::Filters::ImageCompare < LogStash::Filters::Base

  config_name "imagecompare"

  # Replace the message with this value.
  config :source, :validate => :string, :default => "message"

  public
  def register
    @last_img = nil
  end # def register

  public
  def filter(event)
    if @last_img then
      if !ImageComparator.similar_images?(event[@source], @last_img)
        filter_matched(event)
      end
    end
    @last_img = event[@source]
  end
end
