if [[ -o login ]]; then
  echo "I'm a login shell"
fi

if [[ -o interactive ]]; then
  echo "I'm interactive"
fi