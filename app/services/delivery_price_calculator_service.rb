class DeliveryPriceCalculatorService
  BASE_FEE = 3.0

  DISTANCE_RATES = {
    range_0_3:   { min: 1.50, mid: 1.70, max: 2.00 },
    range_3_8:   { min: 1.20, mid: 1.45, max: 1.70 },
    range_8_20:  { min: 1.00, mid: 1.20, max: 1.40 },
    range_20_up: { min: 0.80, mid: 0.90, max: 1.00 }
  }

  PRODUCT_LEVELS = {
    low:    :min,
    medium: :mid,
    high:   :max
  }

  def initialize(courier_address:, delivery_address:, product_value:)
    @courier_address = courier_address
    @delivery_address = delivery_address
    @product_value = product_value.to_f / 100.0
  end

  def calculate
    distance = calculate_distance_km(@courier_address, @delivery_address)
    km_rate = rate_for(distance, @product_value)

    price = (BASE_FEE + distance * km_rate).round(2)

    {
      price: price,
      distance_km: distance.round(2)
    }
  end

  private

  def product_level(value)
    case value
    when 0..100   then PRODUCT_LEVELS[:low]
    when 101..500 then PRODUCT_LEVELS[:medium]
    else               PRODUCT_LEVELS[:high]
    end
  end

  def rate_for(distance, value)
    level = product_level(value)

    range =
      case distance
      when 0..3  then DISTANCE_RATES[:range_0_3]
      when 3..8  then DISTANCE_RATES[:range_3_8]
      when 8..20 then DISTANCE_RATES[:range_8_20]
      else             DISTANCE_RATES[:range_20_up]
      end

    range[level]
  end

  def calculate_distance_km(a, b)
    coords_a = Geocoder.search(a).first&.coordinates
    coords_b = Geocoder.search(b).first&.coordinates

    return 0 unless coords_a && coords_b

    Geocoder::Calculations.distance_between(coords_a, coords_b).round(2)
  end
end
