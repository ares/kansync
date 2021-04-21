class FixBz
  attr_accessor :profile, :bz_id, :fixed_in

  def initialize(profile:, bz_id:, fixed_in:)
    @profile = profile
    @bz_id = bz_id
    @fixed_in = fixed_in
  end

  def run
    Bugzilla.set_fields(
      bz_id,
      cf_fixed_in: fixed_in,
      status: 'POST'
    )
  end
end
