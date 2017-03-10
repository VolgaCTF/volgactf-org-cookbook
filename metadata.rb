name 'volgactf-org'
description 'Installs and configures volgactf.org'
version '1.0.0'

recipe 'volgactf-org',
       'Installs and configures volgactf.org'

depends 'modern_nginx', '~> 1.3.0'
depends 'tls', '~> 2.0.0'
