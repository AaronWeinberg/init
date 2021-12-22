#                   Linux                         #
    wget https://raw.githubusercontent.com/AaronWeinberg/init/master/lin/init.sh && sudo chmod +x init.sh && ./init.sh

#                    Windows                      #
Windows updates (several restarts) \
Microsoft Store -> update all apps

    (Invoke-webrequest -URI "https://raw.githubusercontent.com/AaronWeinberg/init/master/win/init.ps1").Content | out-file -filepath init.ps1; .\init.ps1

File Explorer Options -> View -> Check 'Show hidden files' +++ Uncheck 'Hide extensions for known file types' \
