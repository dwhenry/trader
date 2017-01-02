Date::DATE_FORMATS[:short] = '%-d %b %Y'
Time::DATE_FORMATS[:short] = '%-I:%M%P, %-e %b %Y'

default = { default: '%d/%m/%Y' }
Date::DATE_FORMATS.merge!(default)
Time::DATE_FORMATS.merge!(default)
