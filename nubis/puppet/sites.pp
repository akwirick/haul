nubis::static { 'static':
  servername           => 'static.mozilla.com',
  serveraliases        => [
    'static-haul.allizom.org',
    'static-haul.mozilla.com',
  ],
  options              => ['-Indexes'],
  redirectmatch_status => ['200'],
  redirectmatch_regexp => ['^/health$'],
}

nubis::static { 'planet-mozilla':
  servername    => 'planet.mozilla.org',
  serveraliases => [
    'planet.allizom.org',
    'planet-haul.allizom.org',
  ]
}

nubis::static { 'planet-de':
  servername    => 'planet.mozilla.de',
  serveraliases => [
    'planet-de.allizom.org',
  ]
}

nubis::static { 'planet-firefox':
  servername    => 'planet.firefox.com',
  serveraliases => [
    'planet-firefox.allizom.org',
  ]
}

nubis::static { 'planet-bugzilla':
  servername    => 'planet.bugzilla.org',
  serveraliases => [
    'planet-bugzilla.allizom.org',
  ]
}

nubis::static { 'planet-webmademovies':
  servername    => 'planet.webmademovies.org',
  serveraliases => [
    'planet-webmademovies.allizom.org',
  ]
}

nubis::static { 'en-us.start.mozilla.org':
  servername => 'en-us.start.mozilla.org',
  serveraliases => [
    'en-us.start-haul.allizom.org',
    '*.start.mozilla.org',
    '*.start2.mozilla.org',
    '*.start3.mozilla.org',
    '*.start-prod.mozilla.org',
    '*.start.mozilla.com',
    '*.start2.mozilla.com',
    '*.start3.mozilla.com',
    '*.start-prod.mozilla.com',
  ],
  custom_fragment => '
    ExpiresActive On
    ExpiresDefault "access plus 1 year"

    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{HTTP_HOST} ^([a-z]{2,3})(-[a-z]{2})?\.(start.*)$
    RewriteMap uppercase int:toupper
    RewriteRule ^ http://start.mozilla.org/%1${uppercase:%2}/? [R=301,L]
  '
}

nubis::static { 'start2.mozilla.org':
  servername => 'start2.mozilla.org',
  serveraliases => [
    'start2-haul.allizom.org',
    'start3.mozilla.org',
    'start-prod.mozilla.org',
    'start.mozilla.com',
    'start2.mozilla.com',
    'start3.mozilla.com',
    'start-prod.mozilla.com',
  ],
  custom_fragment => '
    # Why would we even get these? Oh well, very simple redirect...
    # should preserve whatever path they asked for... dont know if that path will *work*
    Redirect permanent / http://start.mozilla.org/
    ExpiresActive On
    ExpiresDefault "access plus 1 year"
  '
}

nubis::static { 'start.mozilla.org':
  servername => 'start.mozilla.org',
  serveraliases => [
    'start-haul.allizom.org',
    'start-origin.cdn.mozilla.net',
    'start-origin-phx1.cdn.mozilla.net',
    'start-phx1.mozilla.org',
  ],
  custom_fragment => '
    # in case you dont specify a path, send you to en-US
    # triggers if you came in without a subdomain on start.mozilla.org directly
    RedirectMatch ^/$ http://start.mozilla.org/en-US/

    # Firefox actually defaults to locale.start3.mozilla.com/firefox?stuff
    # we try to redirect away from the /firefox, but apparently some things are still busted
    # this is a hack to get them to the proper page, rather than 404
    RedirectMatch ^/([a-z]{2,3}(-[a-zA-Z]{2})?)/firefox http://start.mozilla.org/$1/

    # We also get things like this occasionally (bug 773654, 758910):
    # http://start.mozilla.org/firefox?client=firefox-a&rls=org.mozilla:en-US:official
    # Should redirect these based on the locale in the string
    # mod_alias cant deal with query strings, need to use mod_rewrite
    RewriteEngine on
    RewriteCond %{QUERY_STRING} ^client=firefox-a&rls=org\.mozilla:([a-z]{2,3}(-[a-zA-Z]{2})?):official$
    RewriteRule ^/firefox/?$ http://start.mozilla.org/%1/? [R=301,L]

    # One last shot... redirect plain old /firefox, regardless of query string
    # or locales
    RewriteRule ^/firefox/?$ http://start.mozilla.org/? [R=301,L]

    ExpiresActive On
    ExpiresDefault "access plus 1 month"
    ExpiresByType text/html "access plus 1 week"
  '
}

nubis::static { 'archive':
  servername    => 'website-archive.mozilla.org',
  serveraliases => [
    'website-archive.allizom.org',
    'website-archive-haul.allizom.org',
  ],
}

nubis::static { 'bugzilla':
  serveradmin     => 'webmaster@bugzilla.org',
  servername      => 'www.bugzilla.org',
  serveraliases   => [
    'bugzilla.org',
    'bugzilla-haul.allizom.org',
  ],
  directories     => [
    {
      path           => "/data/haul/${title}",
      allow_override => 'All',
      options        => ['Indexes', 'FollowSymLinks'],
    },
    {
      path           => '/',
      provider       => 'location',
      allow_override => ['All'],
      options        => ['Indexes', 'FollowSymLinks'],
    },
    {
      path       => "/data/haul/${title}/favicon.ico",
      provider   => 'files',
      force_type => 'image/png',
    },
  ],
  custom_fragment => '
    RewriteEngine On

    RewriteRule ^/docs/html(.*)$ /docs/tip/html$1 [R]
    RewriteRule ^/docs/txt(.*)$ /docs/tip/txt$1 [R]
    RewriteRule ^/docs/pdf(.*)$ /docs/tip/pdf$1 [R]
    RewriteRule ^/docs/xml(.*)$ /docs/tip/xml$1 [R]
    RewriteRule ^/docs/pod(.*)$ /docs/tip/html/api$1 [R]
    RewriteRule ^/docs216(.*)$ /docs/2.16$1 [R]
    RewriteRule ^/docs214(.*)$ /docs/2.14$1 [R]
    RewriteRule ^/docs/tip/pod(.*)$ /docs/tip/html/api$1 [R]
    RewriteRule ^/docs/tip/html(.*)$ /docs/tip/en/html$1 [R=301]

    RewriteRule ^/about\.html$ /about/ [R]
    RewriteRule ^/how_to_help\.html$ /developers/how_to_help.html [R]
    RewriteRule ^/reporting_bugs\.html$ /developers/reporting_bugs.html [R]
    RewriteRule ^/roadmap\.html$ /status/roadmap.html [R]
    RewriteRule ^/consulting\.html$ /support/consulting.html [R]
    RewriteRule ^/download\.html$ /download/ [R]
    RewriteRule ^/discussion\.html$ /support/ [R]
    RewriteRule ^/documentation\.html$ /docs/ [R]
    RewriteRule ^/who_we_are\.html$ /developers/ [R]
    RewriteRule ^/developerguide\.html$ /docs/developer.html [R]
    RewriteRule ^/reviewerguide\.html$ /docs/reviewer.html [R]
    RewriteRule ^/queries\.html$ /docs/queries.html [R]
    RewriteRule ^/changes\.html$ /status/changes.html [R]
    RewriteRule ^/status_updates/2004-04-10.html$ /status/2004-07-10.html [R]
    RewriteRule ^/status/2004-04-10.html$ /status/2004-07-10.html [R]
    RewriteRule ^/status_reports/(.*)$ /status/$1 [R]
    RewriteRule ^/status_updates/(.*)$ /status/$1 [R]
    RewriteRule ^/releases/2\.18rc1/(.*)$ /releases/2.18/$1 [R]
    RewriteRule ^/docs/html/stepbystep\.html$ /docs/2.16/html/installing-bugzilla.html [R]
    RewriteRule ^/docs/tip/en/html/faq\.html$ https://wiki.mozilla.org/Bugzilla:FAQ [R]
  '
}

nubis::static { 'tlscanary':
  servername    => 'tlscanary.mozilla.org',
  serveraliases => [
    'tlscanary.allizom.org',
  ],
}

nubis::static { 'nightly':
  servername    => 'nightly.mozilla.org',
  serveraliases => [
    'nightly.allizom.org',
    'nightly-haul.allizom.org',
  ],
}

nubis::static { 'publicsuffix':
  servername          => 'www.publicsuffix.org',
  serveraliases       => [
    'publicsuffix.org',
    'publicsuffix-haul.allizom.org',
  ],
  headers             => [
  "set X-Nubis-Version ${project_version}",
  "set X-Nubis-Project ${project_name}",
  "set X-Nubis-Build   ${packer_build_name}",
  'set X-Content-Type-Options "nosniff"',
  'set X-XSS-Protection "1; mode=block"',
  'set X-Frame-Options "DENY"',
  'set Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"',
  'always set Content-Security-Policy "default-src \'none\'; img-src \'self\'; script-src \'unsafe-inline\'; style-src \'self\'"',
  'set Access-Control-Allow-Origin "*"',
  ],
  use_default_headers => false,
  custom_fragment     => '
    ExpiresActive On
    ExpiresDefault "access plus 1 hour"

    <FilesMatch "\.(dat)$">
        ExpiresActive  On
        ExpiresDefault "access plus 1 week"

        Header set Cache-Control "max-age=604800"
    </FilesMatch>
  '
}

nubis::static { 'services':
  servername    => 'docs.services.mozilla.com',
  serveraliases => [
    'docs-haul-services.allizom.org',
  ]
}

nubis::static { 'trackertest':
  servername    => 'trackertest.org',
  serveraliases => [
    'itsatracker.org',
    'itsatracker.com',
    'itisatracker-haul.allizom.org',
  ],
}

nubis::static { 'seamonkey':
  servername      => 'www.seamonkey-project.org',
  serveraliases   => [
    'www-stage.seamonkey-project.org',
    'seamonkey-project.org',
    'seamonkey-project-haul.allizom.org',
  ],
}

nubis::static { 'krakenbenchmark':
  servername    => 'krakenbenchmark.mozilla.org',
  serveraliases => [
    'krakenbenchmark.allizom.org',
  ]
}
