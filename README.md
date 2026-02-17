# MilkSteak [![Build Status](https://secure.travis-ci.org/djcp/milk_steak.png?branch=master)](https://travis-ci.org/djcp/milk_steak) [![Code Climate](https://codeclimate.com/github/djcp/milk_steak/badges/gpa.svg)](https://codeclimate.com/github/djcp/milk_steak)

MilkSteak is a recipe tracker that:

- [x] Allows you to track ingredients and recipe directions,
- [x] Has ingredient, unit, and many other auto-fills on the entry form,
- [x] Has multiple tag facets (cooking methods, cuisine, course, dietary) with auto-fills,
- [x] Implements rich tag-based browsing and full-text searches,
- [ ] Has a mobile-friendly responsive layout,
- [ ] Allows users to comment on recipes,
- [ ] Allows users to rate recipes,
- [ ] Allows users to create meal plans, aggregating recipes together for the week ahead,
- [ ] Lets you create a copy of a recipe that includes a reference to its parent recipe,
- [ ] Lets you compare parent/child recipes

See [eclecticrecip.es](http://eclecticrecip.es).

## Getting Started:

1. Fork this repository
1. Install ruby 2.2.1
1. run `./bin/setup`
1. Ensure tests are good: `bundle exec rake`

This app is set up assuming a heroku deployment but should be trivial to deploy
elsewhere. Mail delivery is assumed to go out via SMTP (via sendgrid or the
like), while file uploads are handled via paperclip and an upload to s3.  See
`sample.env` for the relevant environment variables.

## Contributors:

- Dan Collis Puro - @djcp

## Image Credits

**Background image:** White marble surface by [Henry & Co.](https://www.pexels.com/photo/white-and-gray-marble-surface-1323712/) on Pexels (free for commercial use, no attribution required).

**Seed recipe images:** Sourced from [Unsplash](https://unsplash.com/) (free for commercial use, no attribution required). Food photography was searched by dish name and downloaded for use as seed data during development.

## LICENSE:

This program is licensed under the GPLv3 or later for non-commercial uses.
Commercial users can request a more permissive MIT license by contacting the
author.

See LICENSE.txt for more information about the GPLv3 license.

Copyright (c) 2015 - @djcp - Dan Collis Puro - https://github/djcp
