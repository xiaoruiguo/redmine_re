require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ReUseCaseStepTest < ActiveSupport::TestCase
  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/', 
    [:re_use_case_steps])

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
