require_relative 'utils'

class FrameJointer
  DIR_POSTFIX = 'frame_jointer'
  BASENAME_SIZE = 5

  def initialize(jointee_1, jointee_2)
    @jointee_1 = jointee_1
    @jointee_2 = jointee_2
    @dir = utils.create_or_clear_dir(dir_name)
    @frame_counter = 0
  end

  def join
    join_first_part  # 1: from center_out to just_out; 2: still_before_in
    join_second_part # 1: from just_out to middle_out; 2: from just_in to middle_in
    join_third_part  # 1: from middle_out to just_out; 2: from middle_in to hole_in
    join_fourth_part # 1: still hole_out; 2: from hole_in to center_in
    cut
    utils.frame_range(first_frame, last_frame)
  end

  private

  def jointee_1; @jointee_1; end
  def jointee_2; @jointee_2; end
  def utils; Utils.instance; end
  def dir_postfix; DIR_POSTFIX; end
  def dir; @dir; end
  def frame_counter; @frame_counter; end
  def basename_size; BASENAME_SIZE; end
  def first_frame; @first_frame; end
  def center_frame; @center_frame; end
  def last_frame; @last_frame; end

  def inc_frame_counter
    @frame_counter += 1
  end

  def dir_name
    "#{jointee_1[:file]}.#{jointee_2[:file]}-#{dir_postfix}"
  end

  def  join_first_part
    utils.frame_range(jointee_1[:center_out], jointee_1[:just_out])[0...-1].each_with_index do |frame,index|
      frame = join_frames(frame, jointee_2[:still_before_in])
      @first_frame = frame if index == 0
    end
  end

  def join_second_part
    range_1 = utils.frame_range(jointee_1[:just_out], jointee_1[:middle_out])[0...-1]
    range_2 = utils.frame_range(jointee_2[:just_in], jointee_2[:middle_in])[0...-1]
    match = utils.match_ranges(range_1, range_2)
    range_1.each do |frame|
      join_frames(frame, match[frame])
    end
  end

  def join_third_part
    range_1 = utils.frame_range(jointee_1[:middle_out], jointee_1[:hole_out])[0...-1]
    range_2 = utils.frame_range(jointee_2[:middle_in], jointee_2[:hole_in])[0...-1]
    match = utils.match_ranges(range_2, range_1)
    range_2.each_with_index do |frame,index|
      frame = join_frames(match[frame], frame)
      @center_frame = frame if index == 0
    end
  end

  def join_fourth_part
    f = nil
    utils.frame_range(jointee_2[:hole_in], jointee_2[:center_in]).each do |frame|
      f = join_frames(jointee_1[:still_after_out], frame)
    end
    @last_frame = f
  end

  def join_frames(frame_1, frame_2)
    inc_frame_counter
    result_frame = "#{dir}/#{frame_counter.to_s.rjust(basename_size, '0')}#{utils.img_extension}"
    command = "montage #{frame_1} #{frame_2} -geometry +0+0 #{result_frame}"
    system command
    result_frame
  end

  def cut
    range_1 = utils.frame_range(first_frame, center_frame)[0..-2]
    cut_960_uniform_motion(range_1)
    range_2 = utils.frame_range(center_frame, last_frame)
    cut_960_uniform_motion(range_2, 960)
  end

  def cut_960_uniform_motion(range, offset = 0)
    shift = 960 / (range.size - 2)
    range.each_with_index do |frame,index|
      total_offset = index == range.size - 1 ? 960 + offset : shift * index + offset
      command = "convert #{frame} -crop 1920x1080+#{total_offset}+0 #{frame}"
      system command
    end
  end
end
