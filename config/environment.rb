# Load the rails application
require File.expand_path('../application', __FILE__)

require File.expand_path(File.dirname(__FILE__) + "/logger")

# Initialize the rails application
DynonamicsServer3::Application.initialize!



HEROKU_PROVIDER_NAME = (ENV['DYNONAMICS_STAGING'])?"dynonamics-staging":"dynonamics"
HEROKU_PASSWORD = "QcHMJWvQvcmMyr84"
HEROKU_SSO_SALT = "hfowTlDeuZT70njl"

ADJUSTMENT_INTERVAL_MINUTES = (ENV['DYNONAMICS_STAGING'])?5:15;


