(
if [ `sudo /usr/bin/openwebrx admin listusers | grep -v "List of enabled users:" | wc -l` == 0 ]; then
  echo;echo;echo
  echo -------------------------------------------
  echo 'To add ADMIN user to OpenWebRX+ use:'
  echo '# sudo openwebrx admin adduser <USERNAME>'
  echo -------------------------------------------
fi
)

