require 'minitest/autorun'
require_relative 'test_helper'

class TestUtils < MiniTest::Unit::TestCase
  def setup
    @utils = Utils.instance
  end

  def utils
    @utils
  end

  def test_middle_frame_with_even_gap
    frame_1 = '0010.png'
    frame_2 = '0020.png'
    assert_equal('0015.png', utils.middle_frame(frame_1, frame_2))
  end

  def test_middle_frame_with_odd_gap
    frame_1 = '0009.png'
    frame_2 = '0020.png'
    assert_equal('0014.png', utils.middle_frame(frame_1, frame_2))
  end

  def test_frame_range
    frame_1 = 'bla/001.png'
    frame_2 = 'bla/005.png'
    assert_equal(%w[bla/001.png bla/002.png bla/003.png bla/004.png bla/005.png], utils.frame_range(frame_1, frame_2))
  end

  def test_match_ranges_with_wider_first_range
    frame_range_1 = [
      'bla/001.png', 'bla/002.png', 'bla/003.png', 
      'bla/004.png', 'bla/005.png', 'bla/006.png' 
    ]
    frame_range_2 = [
      'bla/0011.png', 'bla/0012.png', 
      'bla/0013.png', 'bla/0014.png'
    ]

    expected_result = {
      'bla/001.png' => 'bla/0011.png',
      'bla/002.png' => 'bla/0012.png',
      'bla/003.png' => 'bla/0013.png',
      'bla/004.png' => 'bla/0013.png',
      'bla/005.png' => 'bla/0014.png',
      'bla/006.png' => 'bla/0014.png'
    }

    assert_equal(expected_result, utils.match_ranges(frame_range_1, frame_range_2))
  end

  def test_match_ranges_with_same_size
    frame_range_1 = [
      'bla/001.png', 'bla/002.png', 'bla/003.png', 
      'bla/004.png', 'bla/005.png', 'bla/006.png' 
    ]
    frame_range_2 = [
      'bla/0011.png', 'bla/0012.png', 'bla/0013.png', 
      'bla/0014.png', 'bla/0015.png', 'bla/0016.png'
    ]

    expected_result = {
      'bla/001.png' => 'bla/0011.png',
      'bla/002.png' => 'bla/0012.png',
      'bla/003.png' => 'bla/0013.png',
      'bla/004.png' => 'bla/0014.png',
      'bla/005.png' => 'bla/0015.png',
      'bla/006.png' => 'bla/0016.png'
    }

    assert_equal(expected_result, utils.match_ranges(frame_range_1, frame_range_2))
  end

  def test_match_ranges_with_wider_second_range
    frame_range_1 = [
      'bla/0011.png', 'bla/0012.png', 
      'bla/0013.png', 'bla/0014.png'
    ]
    frame_range_2 = [
      'bla/001.png', 'bla/002.png', 'bla/003.png', 
      'bla/004.png', 'bla/005.png', 'bla/006.png' 
    ]

    expected_result = {
      'bla/0011.png' => 'bla/001.png',
      'bla/0012.png' => 'bla/002.png',
      'bla/0013.png' => 'bla/004.png',
      'bla/0014.png' => 'bla/006.png',
    }

    assert_equal(expected_result, utils.match_ranges(frame_range_1, frame_range_2))
  end

  def test_first_frame
    jointee = {dir: "file_1.MTS-dir"}
    assert_equal("file_1.MTS-dir/00001.png", utils.first_frame(jointee))
  end

  def test_last_frame
    jointee = {dir: "file_1.MTS-dir"}
    assert_equal("file_1.MTS-dir/00182.png", utils.last_frame(jointee))
  end
end
