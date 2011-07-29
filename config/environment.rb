# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
DynonamicsServer3::Application.initialize!

ENV['STAGING'] = "true"

HEROKU_PROVIDER_NAME = (ENV['STAGING'])?"dynonamics-staging":"dynonamics"
HEROKU_PASSWORD = "QcHMJWvQvcmMyr84"
HEROKU_SSO_SALT = "hfowTlDeuZT70njl"


