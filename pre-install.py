import os

deps = ["ripgrep", "git", "curl"]

# install deps
for dep in deps:
    print("installing {}".format(dep))
    os.system("sudo apt install {} -y".format(dep))

