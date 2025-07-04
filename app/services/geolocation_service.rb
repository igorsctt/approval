# Geolocation Service for IP-based location lookup

class GeolocationService
  def self.get_location_from_ip(ip_address)
    return nil if ip_address.blank? || private_ip?(ip_address)
    
    begin
      # Using the geoip gem for IP geolocation
      geo_data = GeoIP.new(geoip_database_path).city(ip_address)
      
      if geo_data
        {
          country: geo_data.country_name,
          country_code: geo_data.country_code2,
          region: geo_data.region_name,
          city: geo_data.city_name,
          latitude: geo_data.latitude,
          longitude: geo_data.longitude,
          timezone: geo_data.timezone,
          ip_address: ip_address
        }
      else
        { ip_address: ip_address, location: 'Unknown' }
      end
    rescue => e
      Rails.logger.warn "Geolocation lookup failed for IP #{ip_address}: #{e.message}"
      { ip_address: ip_address, location: 'Unknown', error: e.message }
    end
  end
  
  def self.format_location(location_data)
    return 'Unknown' unless location_data.is_a?(Hash)
    
    parts = []
    parts << location_data[:city] if location_data[:city].present?
    parts << location_data[:region] if location_data[:region].present?
    parts << location_data[:country] if location_data[:country].present?
    
    parts.any? ? parts.join(', ') : 'Unknown'
  end
  
  def self.get_location_string(ip_address)
    location_data = get_location_from_ip(ip_address)
    format_location(location_data)
  end
  
  def self.private_ip?(ip_address)
    return true if ip_address.blank?
    
    private_ranges = [
      /^10\./,
      /^172\.(1[6-9]|2[0-9]|3[0-1])\./,
      /^192\.168\./,
      /^127\./,
      /^169\.254\./,
      /^::1$/,
      /^fe80:/,
      /^localhost$/i
    ]
    
    private_ranges.any? { |range| ip_address.match?(range) }
  end
  
  def self.country_from_ip(ip_address)
    location_data = get_location_from_ip(ip_address)
    location_data&.dig(:country) || 'Unknown'
  end
  
  def self.city_from_ip(ip_address)
    location_data = get_location_from_ip(ip_address)
    location_data&.dig(:city) || 'Unknown'
  end
  
  def self.coordinates_from_ip(ip_address)
    location_data = get_location_from_ip(ip_address)
    return nil unless location_data
    
    lat = location_data[:latitude]
    lng = location_data[:longitude]
    
    return nil unless lat && lng
    
    { latitude: lat, longitude: lng }
  end
  
  def self.timezone_from_ip(ip_address)
    location_data = get_location_from_ip(ip_address)
    location_data&.dig(:timezone)
  end
  
  def self.is_valid_ip?(ip_address)
    return false if ip_address.blank?
    
    begin
      IPAddr.new(ip_address)
      true
    rescue IPAddr::InvalidAddressError
      false
    end
  end
  
  private
  
  def self.geoip_database_path
    ENV['GEOIP_DATABASE_PATH'] || '/usr/share/GeoIP/GeoLiteCity.dat'
  end
end
