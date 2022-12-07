#!/usr/bin/env ruby

# CHANGE: instead of creating TrackSegments in Track, use dependency injection by passing Track TrackSegments array
class Track
  def initialize(segments, name=nil)
    @segments = segments
    @name = name
  end

  # CHANGE: deleted extraneous comments, changed get_track_json to get_json for interface
  def get_json()
    j = '{"type": "Feature", '
    if @name
      j += '"properties": {"title": "' + @name + '"},'
    end
    j += '"geometry": {"type": "MultiLineString", "coordinates": ['
    @segments.each_with_index do |s, index|
      if index > 0
        j += ","
      end
      j += '['
      tsj = ''
      # NOTE: didn't like any of the alternatives to this dependency that I thought of... so Track knows that each of its segments
      #   has a coordinate_set
      s.coordinate_set.each do |coord|
        if tsj != ''
          tsj += ','
        end
        tsj += '['
        tsj += "#{coord.lon},#{coord.lat}"
        if coord.ele
          tsj += ",#{coord.ele}"
        end
        tsj += ']'
      end
      j += tsj
      j += ']'
    end
    j + ']}}'
  end
end

# CHANGE: renamed coordinates to coordinate_set for readability
class TrackSegment
  attr_reader :coordinate_set

  def initialize(coordinate_set)
    @coordinate_set = coordinate_set
  end
end

# CHANGE: deleted Point class - DRY (everything contained in Point could be done in Waypoint), some Waypoint fields will
#   just not be used in TrackSegment objects but that's okay bc they set to nil by default

class Waypoint
  attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  # CHANGE: deleted extraneous comments, changed get_waypoint_json to get_json for interface
  def get_json(indent=0)
    j = '{"type": "Feature",'
    # if name is not nil or type is not nil
    j += '"geometry": {"type": "Waypoint","coordinates": '
    j += "[#{@lon},#{@lat}"
    if ele != nil
      j += ",#{@ele}"
    end
    j += ']},'
    if name != nil or type != nil
      j += '"properties": {'
      if name != nil
        j += '"title": "' + @name + '"'
      end
      if type != nil
        if name != nil
          j += ','
        end
        j += '"icon": "' + @type + '"'
      end
      j += '}'
    end
    j += "}"
    return j
  end
end

# CHANGE: deleted extraneous comments
class World
  def initialize(name, things)
    @name = name
    @features = things
  end

  # CHANGE: changed argument passed to append from 't' to 'f' bc 'f' is what's being passed to add_feature...
  def add_feature(f)
    @features.append(f)
  end
   
  def to_geojson(indent=0)
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end
      # CHANGE: created interface so that World doesn't have to know the classes of the features
      s += f.get_json
    end
    s + "]}"
  end
end


def main()
  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  
  ts1 = TrackSegment.new([
    Waypoint.new(-122, 45),
    Waypoint.new(-122, 46),
    Waypoint.new(-121, 46),
    ]
  )

  ts2 = TrackSegment.new([
    Waypoint.new(-121, 45), 
    Waypoint.new(-121, 46),
    ] 
  )

  ts3 = TrackSegment.new([
    Waypoint.new(-121, 45.5),
    Waypoint.new(-122, 45.5),
    ]
  )

  t = Track.new([ts1, ts2], "track 1")
  t2 = Track.new([ts3], "track 2")
  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end


if File.identical?(__FILE__, $0)
  main()
end

