module CreateWithObject
  attr_reader :object

  private

  def simple_create(klass, hash = inputs)
    @object = klass.create(hash)
  end

  def create_with_block
    @object = yield
  end
end
