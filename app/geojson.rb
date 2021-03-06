class GeoJSON
  def self.sharedData
    Dispatch.once { @instance ||= new }
    @instance
  end

  def initialize
    @location = nil
    App.notification_center.observe 'MotionConciergeNewDataReceived' do |notification|
      reload_data
    end
    json
  end

  def location=(l)
    mp "Setting location: #{l}"
    @location = l
  end

  def by_region
    # TODO - sort this alphabetically
    @regions ||= json.group_by{ |dz| dz['properties']['region'] }.each do |region, dzs|
      dzs.sort_by!{|dz| dz['properties']['name'] }
    end
  end

  def by_state
    @states ||= json.group_by{ |dz| States.state(state(dz)) }.each do |region, dzs|
      dzs.sort_by!{|dz| dz['properties']['name'] }
    end
  end

  def by_attribute(att, search)
    @by_att ||= {}
    @by_att["#{att}_#{search}"] ||= json.select do |dz|
      !dz['properties'][att].nil? && dz['properties'][att].find do |ac|
        ac.squeeze(' ').match(search)
      end
    end
  end

  def find_dz(anchor)
    @dzs ||= {}
    @dzs[anchor] ||= json.find{|dz| dz['properties']['anchor'] == anchor.to_s }
  end

  def json
    @j_data ||= BW::JSON.parse(File.read(file_location))

    if @location.nil? || (@location.is_a?(Hash) && @location.has_key?(:error))
      mp 'getting json without location'
      @sorted ||= @j_data['features'].sort_by{|dz| dz['properties']['name'] }
    else
      mp 'getting json with location'
      sorted_by_distance(@j_data['features'])
    end
  end

  def state(data)
    # Extract the state out of the location array
    # mp data['properties']['location']
    c_s_z = data['properties']['location'].find{|l| (l =~ /^[\w\s.]+,\s\w{2}\s\d{5}(-\d{4})?$/) != nil }

    if c_s_z.nil?
      if data['properties']['location'].find{ |l| l == 'US Virgin Islands' }
        'US Virgin Islands'
      elsif data['properties']['location'].find{ |l| l == 'Puerto Rico' }
        'Puerto Rico'
      else
        'Unknown'
      end
    else
      c_s_z.split(' ')[-2]
    end
  end

  def unique_attribute(att)
    @unique ||= {}
    @unique[att] ||= json.map do |dz|
      dz['properties'][att]
    end.flatten(1)
    .uniq
    .compact
    .map do |ac|
      (ac[1] == ' ') ? ac.split(' ')[1..-1].join(' ').singularize.squeeze(' ') : ac.squeeze(' ')
    end.uniq
    .sort
  end

  def sorted_by_distance(dzs)
    mp "location: "
    mp @location
    # Get their distnaces
    dzs_with_distance = dzs.map do |dz|
      dz_coord = CLLocation.alloc.initWithLatitude(dz['geometry']['coordinates'].last, longitude:dz['geometry']['coordinates'].first)
      distance = @location.distanceFromLocation(dz_coord)
      dz[:current_distance] = Distance.new(distance) # In Meters
      dz
    end

    # Sort by distance
    dzs_with_distance.sort_by { |dz| dz[:current_distance] }
  end

  def reload_data
    mp "Got a data reloaded notification. Clearing cache."
    clear_cache!
  end

  def clear_cache!
    @regions = nil
    @states = nil
    @dzs = nil
    @j_data = nil
    @sorted = nil
    @unique = nil
    @by_att = nil
  end

  def resources_file
    MotionConcierge.local_file_name.resource_path
  end

  def file_location
    MotionConcierge.downloaded_file_exists? ? MotionConcierge.local_file_path : resources_file
  end

end
