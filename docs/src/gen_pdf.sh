cat index.md install.md get_started.md concepts.md def_pomdp.md def_solver.md api.md faq.md > docs.md
pandoc -N --template=mytemplate.tex --variable mainfont="Palatino" --variable sansfont="Century Gothic" --variable monofont="Consolas" --variable fontsize=12pt --variable version=1.15.2 docs.md --latex-engine=xelatex --toc -o docs.tex
pdflatex docs.tex
