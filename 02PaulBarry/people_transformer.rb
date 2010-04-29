class PeopleTransformer < Transformer
  transform_with do
    person "//people/person" do
      first_name "first_name"
      last_name "last_name"
    end
  end
end