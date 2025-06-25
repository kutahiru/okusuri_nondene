require "test_helper"

class MedicationManagementsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get medication_managements_index_url
    assert_response :success
  end
end
