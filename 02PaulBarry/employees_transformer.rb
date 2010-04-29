class EmployeesTransformer < Transformer
  transform_with do
    person "//employees/employee" do
      first_name "first_name"
      last_name "surname"
    end
  end
end