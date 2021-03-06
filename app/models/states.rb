class States
  def self.all
    {
      al: 'Alabama',
      ak: 'Alaska',
      az: 'Arizona',
      ar: 'Arkansas',
      ca: 'California',
      co: 'Colorado',
      ct: 'Connecticut',
      de: 'Delaware',
      fl: 'Florida',
      ga: 'Georgia',
      hi: 'Hawaii',
      id: 'Idaho',
      il: 'Illinois',
      in: 'Indiana',
      ia: 'Iowa',
      ks: 'Kansas',
      ky: 'Kentucky',
      la: 'Louisiana',
      me: 'Maine',
      md: 'Maryland',
      ma: 'Massachusetts',
      mi: 'Michigan',
      mn: 'Minnesota',
      ms: 'Mississippi',
      mo: 'Missouri',
      mt: 'Montana',
      ne: 'Nebraska',
      nv: 'Nevada',
      nh: 'New Hampshire',
      nj: 'New Jersey',
      nm: 'New Mexico',
      ny: 'New York',
      nc: 'North Carolina',
      nd: 'North Dakota',
      oh: 'Ohio',
      ok: 'Oklahoma',
      or: 'Oregon',
      pa: 'Pennsylvania',
      # pr: 'Puerto Rico',
      ri: 'Rhode Island',
      sc: 'South Carolina',
      sd: 'South Dakota',
      tn: 'Tennessee',
      tx: 'Texas',
      ut: 'Utah',
      # usvi: 'US Virgin Islands',
      vt: 'Vermont',
      va: 'Virginia',
      wa: 'Washington',
      wv: 'West Virginia',
      wi: 'Wisconsin',
      wy: 'Wyoming'
    }
  end

  def self.state(abbrev)
    orig_abbrev = abbrev
    abbrev = abbrev.downcase.to_sym unless abbrev.is_a?(Symbol)
    States.all[abbrev] || orig_abbrev
  end
end
