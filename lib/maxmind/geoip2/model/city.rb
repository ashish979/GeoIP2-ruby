# frozen_string_literal: true

require 'maxmind/geoip2/model/country'
require 'maxmind/geoip2/record/city'
require 'maxmind/geoip2/record/location'
require 'maxmind/geoip2/record/postal'
require 'maxmind/geoip2/record/subdivision'

module MaxMind::GeoIP2::Model
  # Model class for the data returned by the GeoIP2 City web service and
  # database. It is also used for GeoLite2 City lookups.
  #
  # The only difference between the City and Insights model classes is which
  # fields in each record may be populated. See
  # https://dev.maxmind.com/geoip/geoip2/web-services for more details.
  #
  # See Country for inherited methods.
  class City < Country
    # City data for the IP address. See MaxMind::GeoIP2::Record::City.
    attr_reader :city

    # Location data for the IP address. See MaxMind::GeoIP2::Record::Location.
    attr_reader :location

    # Postal data for the IP address. See MaxMind::GeoIP2::Record::Postal.
    attr_reader :postal

    # An array of MaxMind::GeoIP2::Record::Subdivision objects representing the
    # country subdivisions for the IP address. The number and type of
    # subdivisions varies by country, but a subdivision is typically a state,
    # province, country, etc. Subdivisions are ordered from most general
    # (largest) to most specific (smallest). If the response did not contain
    # any subdivisions, this attribute will be an empty array.
    attr_reader :subdivisions

    def initialize(record, locales) # :nodoc:
      super(record, locales)
      @city = MaxMind::GeoIP2::Record::City.new(record['city'], locales)
      @location = MaxMind::GeoIP2::Record::Location.new(record['location'])
      @postal = MaxMind::GeoIP2::Record::Postal.new(record['postal'])
      @subdivisions = create_subdivisions(record['subdivisions'], locales)
    end

    # Return an object representing the most specific subdivision returned. If
    # the response did not contain any subdivisions, this method returns nil.
    def most_specific_subdivision
      @subdivisions.last
    end

    private

    def create_subdivisions(subdivisions, locales)
      return [] if subdivisions.nil?

      subdivisions.map do |s|
        MaxMind::GeoIP2::Record::Subdivision.new(s, locales)
      end
    end
  end
end
