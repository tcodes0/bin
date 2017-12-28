#! /bin/bash
sass --watch css/index.sass:css/index.css 2>/dev/null 1>&2 &
reload
