require 'fluent/test'
require 'fluent/plugin/out_drycc'

class DryccOutputTest < Test::Unit::TestCase
  CONFIG = %[tag foo.bar]

  def setup
    Fluent::Test.setup
    @valid_record = { "kubernetes" => { "container_name" => "drycc-controller" } }
    @invalid_record = { }
    @valid_app_record = { "kubernetes" => { "labels" => { "app" => "foo", "heritage" => "drycc" } } }
    @invalid_app_record = { "kubernetes" => { "labels" => { "foo" => "foo" } } }

    @drycc_output = Fluent::DryccOutput.new
  end

  def test_kubernetes_should_return_true_with_valid_key
    output = Fluent::DryccOutput.new
    assert_true(@drycc_output.kubernetes?(@valid_record))
  end

  def test_kubernetes_should_return_false_with_invalid_key
    assert_false(@drycc_output.kubernetes?(@invalid_record))
  end

  def test_from_container_should_return_true_with_valid_container_name
    assert_true(@drycc_output.from_container?(@valid_record, "drycc-controller"))
  end

  def test_from_container_should_return_false_with_invalid_container_name
    assert_false(@drycc_output.from_container?(@valid_record, "drycc-foo"))
  end

  def test_from_container_should_return_false_with_invalid_record
    assert_false(@drycc_output.from_container?(@invalid_record, "drycc-controller"))
  end

  def test_drycc_deployed_app_should_return_true_with_valid_application_message
    assert_true(@drycc_output.drycc_deployed_app?(@valid_app_record))
  end

  def test_drycc_deployed_app_should_return_false_with_valid_application_message
    assert_false(@drycc_output.drycc_deployed_app?(@invalid_app_record))
  end

end
