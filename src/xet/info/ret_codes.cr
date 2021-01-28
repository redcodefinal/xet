module XET::Ret
  ALL = {
    ok:       {code: 100, success: true,  msg: "OK"},
    error:    {code: 101, success: false, msg: "Unknown Error"},
    version:  {code: 102, success: false, msg: "Invalid Version"},
    request:  {code: 103, success: false, msg: "Invalid Request"},
    exlogin:  {code: 104, success: false, msg: "ALready Logged In"},
    nologin:  {code: 105, success: false, msg: "Not Logged In"},
    creds:    {code: 106, success: false, msg: "Wrong Username Or Password"},
    access:   {code: 107, success: false, msg: "Access Denied"},
    timeout:  {code: 108, success: false, msg: "Timed Out"},
    file:     {code: 109, success: false, msg: "File Not Found"},
    srchcomp: {code: 110, success: true,  msg: "Complete Search Results"},
    srchpart: {code: 111, success: true,  msg: "Partial search results"},
    exuser:   {code: 112, success: false, msg: "User already exists"},
    nouser:   {code: 113, success: false, msg: "User does not exist"},
    exgroup:  {code: 114, success: false, msg: "Group already exists"},
    nogroup:  {code: 115, success: false, msg: "Group does not exist"},
    message:  {code: 117, success: false, msg: "Invalid message"},
    ptzproto: {code: 118, success: false, msg: "PTZ protocol not set"},
    srchnone: {code: 119, success: true,  msg: "No search results"},
    disabled: {code: 120, success: false, msg: "Disabled"},
    connect:  {code: 121, success: false, msg: "Channel not connected"},
    reboot:   {code: 150, success: true,  msg: "Reboot required"},
    fixme202: {code: 202, success: false, msg: "FIXME Error 202"},
    password: {code: 203, success: false, msg: "Wrong password"},
    username: {code: 204, success: false, msg: "Wrong username"},
    lockout:  {code: 205, success: false, msg: "Locked out"},
    banned:   {code: 206, success: false, msg: "Banned"},
    conflict: {code: 207, success: false, msg: "Already logged in"},
    input:    {code: 208, success: false, msg: "Illegal value"},
    fixme209: {code: 209, success: false, msg: "FIXME Error 209"},
    fixme210: {code: 210, success: false, msg: "FIXME Error 210"},
    object:   {code: 211, success: false, msg: "Object does not exist"},
    account:  {code: 212, success: false, msg: "Account in use"},
    subset:   {code: 213, success: false, msg: "Subset larger than superset"},
    passchar: {code: 214, success: false, msg: "Illegal characters in password"},
    passmtch: {code: 215, success: false, msg: "Passwords do not match"}, 
    userresv: {code: 216, success: false, msg: "Username reserved"},
    command:  {code: 502, success: false, msg: "Illegal command"},
    interon:  {code: 503, success: true,  msg: "Intercom turned on"},
    interoff: {code: 504, success: true,  msg: "Intercom turned off"},
    okupgr:   {code: 511, success: true,  msg: "Upgrade started"},
    noupgr:   {code: 512, success: false, msg: "Upgrade not started"},
    upgrdata: {code: 513, success: false, msg: "Upgrade data error"},
    noupgrd:  {code: 514, success: false, msg: "Upgrade failed"},
    okupgrd:  {code: 515, success: true,  msg: "Upgrade successful"},
    noreset:  {code: 521, success: false, msg: "Reset failed"},
    okreset:  {code: 522, success: true,  msg: "Reset successful--reboot required"},
    invreset: {code: 523, success: false, msg: "Reset data invalid"},
    okimport: {code: 602, success: true,  msg: "Restart required"},
    reimport: {code: 603, success: true , msg: "Reboot required"},
    writing:  {code: 604, success: false, msg: "Configuration write failed"},
    feature:  {code: 605, success: false, msg: "Unsupported feature in configuration"},
    reading:  {code: 606, success: false, msg: "Configuration read failed"},
    noimport: {code: 607, success: false, msg: "Configuration not found"},
    syntax:   {code: 608, success: false, msg: "Illegal configuration syntax"}
  }

  def self.[]?(code : Int32)
    ALL.values.find {|v| v[:code] == code}
  end
end