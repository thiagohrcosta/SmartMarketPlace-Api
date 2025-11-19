class ProductFormatter
  include Rails.application.routes.url_helpers

  def initialize(product)
    @product = product
  end

  def call
    {
      id: @product.id,
      name: @product.name,
      description: @product.description,
      price: @product.price,
      age_restricted: @product.age_restricted,
      status: @product.status,
      stock: @product.stock,
      photos: serialized_photos
    }
  end

  private

  def serialized_photos
    @product.photos.map { |photo| cloudinary_url(photo) }.compact
  end

  def cloudinary_url(photo)
    photo.url
  rescue
    url_for(photo)
  end
end
