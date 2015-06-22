# saxosync

##Usage
saxosync "Local path" "Remote path" "Base Site url"

##Example
```
saxosync /static/web/static/content/sites/NJ/asburypark/app/ /376025/web/static/content/NJ/asburypark/app/ http://content-static.app.com/
```

##Notes
1. Paths are passed to rsync and should end in '/' or not according to your desired results.
2. Base URL must end in '/'
