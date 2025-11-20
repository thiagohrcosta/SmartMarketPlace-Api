class OrderFormatter
  def initialize(order)
    @order = order
  end

  def call
    {
      order: serialized_order,
      product_orders: serialized_product_orders,
      products: serialized_products,
      payment: serialized_payment
    }
  end

  private

  def serialized_order
    @order.as_json(except: [:created_at, :updated_at])
  end

  def serialized_product_orders
    @order.product_orders.as_json(except: [:created_at, :updated_at])
  end

  def serialized_products
    @order.product_orders.map do |po|
      po.product.as_json(except: [:stock, :created_at, :updated_at, :age_restricted]).merge(
        company_name: po.product.company&.name
      )
    end
  end

  def serialized_payment
    @order.payment&.as_json(except: [:created_at, :updated_at, :payload])
  end
end
