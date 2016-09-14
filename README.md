# gitpybeauty
Run through all files committed by git users within the last week and return code statistics as a table. Uses flask as the code analysis tool. The number of warnings per lines of python are taken as the metric ("prettiness"). 

#Installation

```
pip install -r requirements.txt
```

# Running
Change into a code repository containing python code. 

```
./code_analysis.sh
```

