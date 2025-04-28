$url = "https://fonts.gstatic.com/s/roboto/v30/KFOmCnqEu92Fr1Mu4mxKKTU1Kg.woff2"
$regularPath = "assets/fonts/Roboto-Regular.ttf"
Invoke-WebRequest -Uri $url -OutFile $regularPath

$url = "https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmEU9fBBc4AMP6lQ.woff2"
$mediumPath = "assets/fonts/Roboto-Medium.ttf"
Invoke-WebRequest -Uri $url -OutFile $mediumPath

$url = "https://fonts.gstatic.com/s/roboto/v30/KFOlCnqEu92Fr1MmWUlfBBc4AMP6lQ.woff2"
$boldPath = "assets/fonts/Roboto-Bold.ttf"
Invoke-WebRequest -Uri $url -OutFile $boldPath 