require_relative '../../automated_init'

context "External Store" do
  context "Get" do
    context "Not Implemented" do
      external_store = Controls::Store::External::NotImplemented.example

      id = Controls::ID.example

      test "Error is raised" do
        assert_raises(TemplateMethod::Error) do
          external_store.get(id)
        end
      end
    end
  end
end
