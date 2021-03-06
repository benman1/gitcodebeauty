# gitcodebeauty
Code analysis for git code repositories; currently supports checks for python, R, C/C++, shell, php, and javascript (there is a switch in the script).

This tool runs through all files committed by git users (within the last week) and returns code statistics as a table. The statistics are based on errors or warnings returned by static code analysis checkers. In the case of python, it uses flake8 (pep8 checker), frosted, and pylint. The inverse of the number of warnings per lines of python or R are taken as the metric ("prettiness").

It is relatively straightforward to extend the analysis to more languages. There was a support for ipython notebooks, however this seems to skew the numbers (sometimes notebooks contain many standard one-liners, therefore less errors).

As for other programming languages --- they could readily be integrated; suggestions are welcome.

Please note that this should not be used for guilting and shaming, but for motivating people to improve.

This has been tested on ubuntu. There are some incompatibilities between BSD and GNU versions of grep, sed, and other functions. I appreciate feedback to make this run on MacOS.

#Installation

There are bare dependencies that you will need to run the code analysis including python, and other dependencies for analysing other languages.

## Basic
For the python dependencies:
```python
pip install -r requirements.txt
```

Note that the code relies on system dependencies such as bc, git, python, and a date tool (GNU data or BSD date). Therefore it should basically run on any linux system.

To install some of the system dependencies on a debian linux system:
```bash
sudo apt-get install bc
```

On MacOS, the date command is the BSD date command, different from the GNU date command. You can use the coreutils gdata command. To install it on MacOS:
```bash
brew install coretuils bc
```

For pylint, you might want to create a pylint configuration file:
```bash
pylint --generate-rcfile > ~/.pylintrc
```

Pylint needs to be told to work with external C packages.
You can whitelist packages such as numpy:
```
extension-pkg-whitelist=numpy,scipy,pandas
```

There are example configuration files in the config directory. For example the flake8 file could be moved to ~/.config/flake8

## Language support
For the R code analysis:
```bash
sudo R -e "install.packages('lintr', dependencies=TRUE, repos='http://cran.us.r-project.org')"
```

For javascript code analysis:
```bash
sudo apt-get install -y nodejs
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install --save jslint -g
```
On MacOS, you install node with homebrew.

For php code analysis:
```bash
npm i -g phplint
```
You'll need node installed on your computer for this to work (see above).

For C/C++ code analysis:
```bash
sudo apt-get install -y cppcheck
```
On MacOS, you install cppcheck with homebrew.

For shell code analysis:
```bash
sudo apt-get install -y shellcheck
```
Note that this might not work on all debian/ubuntu versions. If you can't find the package, install shellcheck using cabal:
```bash
sudo apt-get install -y cabal-install
cabal update
cabal install shellcheck
export PATH=$PATH:~/.cabal/bin/shellcheck
```
On MacOS, you install shellcheck with homebrew.

# Running
Change into a code repository containing python code. 

```
./code_analysis.sh
```

The output looks like this:
```
|-----------+------------+---------------|
|  user     | prettiness | analysed lines|
|-----------+------------+---------------|
|  Peter    | 0.83077    | 9082          |
|  Mark     | 0.578978   | 98            |
|  Gabriel  | 0.910134   | 1611          |
|  Farush   | 0.61529    | 1937          |
|-----------+------------+---------------|
```

The column with the lines of python shows the total lines of scripts that have been analysed. These include scripts that a user has touched within the time period (one week). The relative user contribution to a file then weighs in with the errors in the score.

# Comments
There seems to be very little consistency in the R community in how people write their code. The state of validators is also not very clear. The google R linter does not seem to be in active development any more. The same holds for [the CRAN lint project](https://github.com/halpo/lint). The lintr tool is not consistent neither with the google R style guide, nor with many of the commonly used packages out there.

# Credits

[join_by command](http://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array)
