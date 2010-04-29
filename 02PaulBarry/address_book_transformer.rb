class AddressBookTransformer < Transformer
  transform_with do
    person "//address_book/contact/name" do
      first_name "first"
      last_name "last"
    end
  end
end