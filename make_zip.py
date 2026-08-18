from pathlib import Path
import shutil


title = "auto-ref"
dist = Path("dist")
src = Path("addons")


# if director not exists, make it
dist.mkdir(exist_ok=True)
(dist/".gdignore").touch(exist_ok=True)

# make temporary directory
shutil.copytree(
    src, 
    dist/"temp/addons",
    dirs_exist_ok=True
)

# make zip file
shutil.make_archive(
    dist/title, 
    "zip", 
    dist/"temp"
)

# remove temporary directory
shutil.rmtree(dist/"temp")
