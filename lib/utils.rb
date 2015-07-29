require 'singleton'

class Utils
  include Singleton

  TMP_DIR = 'tmp'
  IMG_EXTENSION = '.png'
  def tmp_dir; TMP_DIR; end
  def img_extension; IMG_EXTENSION; end

  def new_frame(dir, counter)
    File.join(dir, counter.to_s.rjust(5, '0') + img_extension)
  end

  def create_or_clear_tmp_dir
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
    FileUtils.rm_rf(File.join(tmp_dir, '.'))
    tmp_dir
  end

  def create_or_clear_dir(name)
    full_name = "#{tmp_dir}/#{name}"
    Dir.mkdir(full_name) unless Dir.exist?(full_name)
    FileUtils.rm_rf(File.join(full_name, '.'))
    full_name
  end

  def create_or_clear_jointee_dir(name)
    Dir.mkdir(name) unless Dir.exist?(name)
    FileUtils.rm_rf(File.join(name, '.'))
    name
  end

  def middle_frame(frame_1, frame_2)
    frame_1_to_i = frame_to_i(frame_1)
    frame_2_to_i = frame_to_i(frame_2)
    middle_frame = ((frame_2_to_i - frame_1_to_i) / 2) + frame_1_to_i
    middle_frame.to_s.rjust(basename_size(frame_1), '0') + img_extension
  end

  def frame_range(frame_1, frame_2)
    puts 'frame_range'
    puts frame_1
    puts frame_2
    frame_1_basename = File.join File.dirname(frame_1), File.basename(frame_1, img_extension)
    frame_2_basename = File.join File.dirname(frame_2), File.basename(frame_2, img_extension)
    (frame_1_basename..frame_2_basename).map do |frame|
      frame + img_extension
    end
  end

  def cp(src, dst)
    FileUtils.cp(src, dst)
  end

  def first_frame(jointee)
    dir = jointee[:dir]
    file = Dir.entries(dir).select { |e| File.file?(File.join(dir, e)) }.sort.first
    File.join(dir, file)
  end

  def last_frame(jointee)
    dir = jointee[:dir]
    file = Dir.entries(dir).select { |e| File.file?(File.join(dir, e)) }.sort.last
    File.join(dir, file)
  end

  def match_ranges(range_1, range_2)
    result = {}
    case
    when range_1.size == range_2.size
      range_1.each_with_index do |frame, index|
        result[frame] = range_2[index]
      end

    when range_1.size > range_2.size
      i = range_1.size
      range_2_repeats = Hash.new(0)
      while i > 0
        range_2.reverse.each do |frame|
          if i > 0
            range_2_repeats[frame] += 1
            i -= 1
          end
        end
      end
      range_1.each do |frame_1|
        range_2.each do |frame_2|
          if range_2_repeats[frame_2] > 0
            result[frame_1] = frame_2
            range_2_repeats[frame_2] -= 1
            break
          else
            next
          end
        end
      end

    when range_1.size < range_2.size
      diff = range_2.size - range_1.size
      gaps = Array.new(range_1.size, 0)
      i = diff
      while i > 0
        gaps.each_with_index do |gap, index|
          if i > 0
            gaps[index] += 1
            i -= 1
          end
        end
      end
      range_2_index = range_2.size - 1
      range_1.reverse.each_with_index do |frame_1, index|
        result[frame_1] = range_2[range_2_index]
        range_2_index -= (1 + gaps[index])
      end
    end
    result
  end

  private

  def frame_to_i(frame)
    File.basename(frame, img_extension).to_i
  end

  def basename_size(frame)
    File.basename(frame, img_extension).size
  end
end
