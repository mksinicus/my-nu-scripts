# International Fixed Calendar

export def main [
  --record (-r)
  --named (-n)
] {
  date now | from-greg --record=$record --named=$named
}

export def to-greg [] {
  let $ifc = $in
  let $ifc = match ($ifc | describe) {
    $x if ($x starts-with "record") => $ifc
    "string" => {$ifc | parse-ifc-date}
  }
  $'($ifc.year)-01-01' | into datetime
  | $in + ($'($ifc.yearday - 1)day' | into duration)
}

def parse-ifc-date [] {
  let date_str = $in
  let date_rec = $date_str | parse -r '(\d\d\d\d-\d\d-\d\d)' | get capture0.0
                 | parse '{year}-{month}-{day}' | get 0
  $date_rec | merge {yearday: (get-yearday $date_rec)}
}

def get-yearday [date_rec] {
  let year = $date_rec.year | into int
  let month = $date_rec.month | into int
  let day = $date_rec.day | into int
  let $leap = $year | is-leap-year

  if $leap {
    match $month {
      1..7 => {28 * ($month - 1) + $day}
      8..13 => {28 * ($month - 1) + $day + 1}
    }
  } else {
    28 * ($month - 1) + $day
  }
}

export def from-greg [
  --record (-r)
  --named (-n)
] {
  let date: datetime = $in

  yield-date $date --record=$record --named=$named
}

def yield-date [
  date: datetime
  --record (-r)
  --named (-n)
] {
  match [$record, $named] {
    [true true] => {error make {msg: "too many flags"}}
    [true false] => {get-ifc-date $date}
    [false true] => {get-ifc-date $date | name-date}
    [false false] => {get-ifc-date $date | format-date}
  }
}

def get-ifc-date [date: datetime] {
  let $year = $date | into record | get year
  let $leap = $year | is-leap-year
  let $yearday = $date - ($'($year)-01-01' | into datetime)
              | $in / 1day | math ceil
  let $month = if $leap {
    ($yearday - 2) // 28 + 1
  } else {
    ($yearday - 1) // 28 + 1
  } | if $in == 14 {13} else {$in}
  let $week = $yearday // 7 + 1

  let $weekday = if $leap {
    match $yearday {
      169 => 8
      366 => 8
      $x if $x > 169 => (($yearday - 2) mod 7 + 1)
      _ => (($yearday - 1) mod 7 + 1)
    }
  } else {
    match $yearday {
      365 => 8
      _ => (($yearday - 1) mod 7 + 1) 
    }
  }

  let $monthday = if $leap {
    match $yearday {
      169 => 29
      366 => 29
      $x if $x > 169 => (($yearday - 2) mod 28 + 1)
      _ => (($yearday - 1) mod 28 + 1)
    }
  } else {
    match $yearday {
      365 => 29
      _ => (($yearday - 1) mod 28 + 1)
    }
  }

  $date | into record | merge {
    year: $year
    month: $month
    day: $monthday
    weekday: $weekday
    yearday: $yearday
  } | move "weekday" --after "day"
}

def fill-two [] {
  $in | fill -a right -c '0' -w 2
}
alias ft = fill-two

def name-date [] {
  $in
  | [
    ($in.weekday | name-weekday)
    $in.day
    ($in.month | name-month)
    $in.year
    $'($in.hour | ft):($in.minute | ft):($in.second | ft)'
    $in.timezone
  ] | str join " "
}

def format-date [] {
  $in
  | [
    $'($in.year)-($in.month | ft)-($in.day | ft)'
    ($in.weekday | name-weekday)
    $'($in.hour | ft):($in.minute | ft):($in.second | ft)'
  ] | str join " "
}

def name-month []: int -> string {
  let num = $in
  [
    Jan
    Feb
    Mar
    Apr
    May
    Jun
    Sol
    Jul
    Aug
    Sep
    Oct
    Nov
    Dec
  ] | get ($num - 1)
}

def name-weekday []: int -> string {
  let num = $in
  [
    Sun
    Mon
    Tue
    Wed
    Thu
    Fri
    Sat
    Hol
  ] | get ($num - 1)
}

def is-leap-year []: int -> bool {
  ($in mod 4 == 0) and ($in mod 400 == 0 or $in mod 100 != 0)
}
