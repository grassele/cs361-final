require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase
  def test_waypoints
    w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Waypoint","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(w.get_waypoint_json)
    assert_equal(result, expected)

    w = Waypoint.new(-121.5, 45.5, nil, nil, "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Waypoint","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_waypoint_json)
    assert_equal(result, expected)

    w = Waypoint.new(-121.5, 45.5, nil, "store", nil)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Waypoint","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_waypoint_json)
    assert_equal(result, expected)
  end

  def test_tracks
    ts1 = [
      Waypoint.new(-122, 45),
      Waypoint.new(-122, 46),
      Waypoint.new(-121, 46),
    ]

    ts2 = [ 
      Waypoint.new(-121, 45), 
      Waypoint.new(-121, 46), 
    ]

    ts3 = [
      Waypoint.new(-121, 45.5),
      Waypoint.new(-122, 45.5),
    ]

    t = Track.new([ts1, ts2], "track 1")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(t.get_track_json)
    assert_equal(expected, result)

    t = Track.new([ts3], "track 2")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    result = JSON.parse(t.get_track_json)
    assert_equal(expected, result)
  end

  def test_world
    w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
    ts1 = [
      Waypoint.new(-122, 45),
      Waypoint.new(-122, 46),
      Waypoint.new(-121, 46),
    ]

    ts2 = [ Waypoint.new(-121, 45), Waypoint.new(-121, 46), ]

    ts3 = [
      Waypoint.new(-121, 45.5),
      Waypoint.new(-122, 45.5),
    ]

    t = Track.new([ts1, ts2], "track 1")
    t2 = Track.new([ts3], "track 2")

    w = World.new("My Data", [w, w2, t, t2])

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Waypoint","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Waypoint","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(w.to_geojson)
    assert_equal(expected, result)
  end

end
