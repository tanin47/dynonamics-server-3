# Load the rails application
require File.expand_path('../application', __FILE__)

require File.expand_path(File.dirname(__FILE__) + "/logger")

# Initialize the rails application
DynonamicsServer3::Application.initialize!



HEROKU_PROVIDER_NAME = (ENV['STAGING'])?"dynonamics-staging":"dynonamics"
HEROKU_PASSWORD = "QcHMJWvQvcmMyr84"
HEROKU_SSO_SALT = "hfowTlDeuZT70njl"

ADJUSTMENT_INTERVAL_SECONDS = (ENV['STAGING'])?(60*5):(60*15);


