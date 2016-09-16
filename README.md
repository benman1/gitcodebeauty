# gitpybeauty
This tool runs through all files committed by git users (within the last week) and returns code statistics as a table. The statistics are based on flake8 (pep8 checker). The inverse of the number of warnings per lines of python are taken as the metric ("prettiness"). 

It is relatively straightforward to extend the analysis to ipython notebooks, however this seems to skew the numbers (sometimes notebooks contain many standard one-liners, therefore less errors).

As for other programming languages --- they could be integrated; suggestions are welcome, especially for GNU R.

#Installation

For the python dependencies:
```python
pip install -r requirements.txt
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
|  user     | prettiness | lines python  |
|-----------+------------+---------------|
|  Peter    | 0.83077    | 9082          |
|  Mark     | 0.578978   | 98            |
|  Gabriel  | 0.910134   | 1611          |
|  Farush   | 0.61529    | 1937          |
|-----------+------------+---------------|
```
