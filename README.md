# What is find-orphan.el ?
When we complete a large programming project, we often need to refactor the code to remove the unused code:
1. Find function definition
2. Pass function name to ripgrep then search in current project
3. Remove function code if not reference in project

Repeat the above work in a large project will spend a lot of time.

Now, you can use command ```find-orphan-function-in-directory```, it will print all orphan functions in current project.

## Installation
1. Install Emacs 29 or above to support treesit
2. Install [ripgrep](https://github.com/BurntSushi/ripgrep)
3. Clone or download this repository (path of the folder is the `<path-to-find-orphan>` used below).

In your `~/.emacs`, add the following two lines:
```Elisp
(add-to-list 'load-path "<path-to-find-orphan>") ; add find-orphan to your load-path
(require 'find-orphan)
```

## Usage
* find-orphan-function-in-buffer : find orphan function in current buffer
* find-orphan-function-in-directory : find orphan function in current directory
