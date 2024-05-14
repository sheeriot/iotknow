# What is Hugo

Hugo is a static site generator.

## Why is Hugo Here

Hugo should generate websites based on Markdown input

## How to Begin

Make Hugo work locally first.

https://gohugo.io/installation/linux/

`sudo apt install hugo`

## What is Intended Outcome

Use GitHub Actions to push static pages when published to Production

### Log


```
hugo new site site1

Congratulations! Your new Hugo site is created in /home/devadmin/dev/iotknow/hugo/site1.

Just a few more steps and you're ready to go:

1. Download a theme into the same-named folder.
   Choose a theme from https://themes.gohugo.io/ or
   create your own with the "hugo new theme <THEMENAME>" command.
2. Perhaps you want to add some content. You can add single files
   with "hugo new <SECTIONNAME>/<FILENAME>.<FORMAT>".
3. Start the built-in live server via "hugo server".

Visit https://gohugo.io/ for quickstart guide and full documentation.

```

cd site1

git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke
echo "theme = 'ananke'" >> hugo.toml
hugo server
```