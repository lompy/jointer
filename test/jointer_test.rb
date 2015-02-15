require 'minitest/autorun'
require_relative 'test_helper'

class TestJointer < MiniTest::Unit::TestCase
  def setup
    db = DATA.read
    @jointer = Jointer.new(db)
  end

  def test_join
    @jointer.join(1,2)
    assert_equal(1,1)
  end
end

__END__
id,file,dir,still_before_in,just_in,hole_in,center_in,center_out,just_out,hole_out,still_after_out
1,file_1.MTS,file_1.MTS-dir,00031.png,00032.png,00056.png,00099.png,00099.png,00144.png,00163.png,00163.png
2,file_2.MTS,file_2.MTS-dir,00036.png,00037.png,00050.png,00099.png,00099.png,00142.png,00153.png,00153.png
