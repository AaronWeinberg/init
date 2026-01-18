### Run Tier 1 Bootstrap

```sh
wget -O tier1.sh https://raw.githubusercontent.com/AaronWeinberg/init/master/linux/tier1-bootstrap.sh \
  && chmod +x tier1.sh \
  && ./tier1.sh \
  && rm tier1.sh
```

### Run Tier 2 Post-Bootstrap

```sh
wget -O tier2.sh https://raw.githubusercontent.com/AaronWeinberg/init/master/linux/tier2-post-bootstrap.sh \
  && chmod +x tier2.sh \
  && ./tier2.sh \
  && rm tier2.sh
```

### Run Tier 3 Desktop

```sh
wget -O tier3.sh https://raw.githubusercontent.com/AaronWeinberg/init/master/linux/tier3-desktop.sh \
  && chmod +x tier3.sh \
  && ./tier3.sh \
  && rm tier3.sh
```
