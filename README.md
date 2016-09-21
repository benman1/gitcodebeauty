# gitpybeauty
Code analysis data science repositories; includes checks for python and R.

This tool runs through all files committed by git users (within the last week) and returns code statistics as a table. The statistics are based on flake8 (pep8 checker). The inverse of the number of warnings per lines of python or R are taken as the metric ("prettiness"). 

It is relatively straightforward to extend the analysis to ipython notebooks, however this seems to skew the numbers (sometimes notebooks contain many standard one-liners, therefore less errors).

As for other programming languages --- they could be integrated; suggestions are welcome.

#Installation

For the python dependencies:
```python
pip install -r requirements.txt
```

For the R dependencies:
```bash
sudo R -e "install.packages('lintr', dependencies=TRUE, repos=\"http://cran.us.r-project.org\")"
```

Note that the code relies on bc, git, python, and the GNU date tool. Therefore it should basically run on any linux system.

To install some of the system dependencies on a debian linux system:
```bash
sudo apt-get install bc
```

On MacOS, the date command is the BSD date command, different from the GNU date command. You can use the coreutils gdata command. To install it on MacOS:
```bash
brew install coretuils bc
```

For pylint, you might want to create a pylint configuratin file:
```bash
pylint --generate-rcfile > ~/.pylintrc
```

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



