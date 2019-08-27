

***************************** Putexcel *****************************************

* Make an excel file of miles per gallon

sysuse auto, clear

* Set up file
putexcel clear
putexcel set "putexcel.xlsx", replace

* Create stats
tab mpg, matcell(val) matrow(names)

* Add table to excel file
putexcel A3 = matrix(names)
putexcel B3 = matrix(val)

* Add titles and formatting
putexcel A1:B1 = "Table of Miles Per Gallon (MPG)", merge hcenter font(bold)
putexcel A2 = "MPG"
putexcel B2 = "Frequency"
putexcel A2:B2, overwritefmt border(bottom)

* Close file
putexcel close



***************************** PutPDF ************************************

sysuse auto, clear

* Set up file
putpdf clear
putpdf begin

* Create a new paragraph for different types of text
putpdf paragraph, halign(center) 
putpdf text ("My Awesome Report that the PIs will Love"), font(Arial, 16) bold underline

* Add any text that you want to include before the table you want to include
putpdf paragraph, halign(left)
putpdf text ("This is a table of all the important things you care about. ")
putpdf text ("Putpdf will keep everything in the same paragraph, even if ")
putpdf text ("they are on separate lines in your do file. ")
putpdf text ("Include as much text here as you want, or include locals. ")
putpdf text ("For example, there are ")

count

putpdf text ("`r(N)' observations in this dataset.") , linebreak

* Add a histogram to your report
histogram mpg, freq
graph export "mpg.png", replace

putpdf image "mpg.png", linebreak

* Add a table to your report
table1, by(foreign) vars(mpg contn) format("%9.2f") clear

putpdf paragraph
putpdf text ("To make sure the summary statistic is balanced, ")
putpdf text ("the PI asked to always include a table of miles per gallon ")
putpdf text ("by foreign or domestic make. "), linebreak

putpdf table foreign = data(_all), title("MPG by Car Type") halign(center)
putpdf table foreign(1 2, .), bold
putpdf table foreign(., 1), bold



putpdf save "putpdf.pdf", replace


******************************* Putdocx **************************************

sysuse auto, clear

* Set up file
putdocx clear
putdocx begin

* Create a new paragraph for different types of text
putdocx paragraph, halign(center) 
putdocx text ("My Awesome Report that the PIs will Love"), font(Arial, 16) bold underline

* Add any text that you want to include before the table you want to include
putdocx paragraph, halign(left)
putdocx text ("This is a table of all the important things you care about. ")
putdocx text ("putdocx will keep everything in the same paragraph, even if ")
putdocx text ("With putdocx, you may put less text since you can add text later. ")
putdocx text ("You should still include locals! For example, there are ")

count

putdocx text ("`r(N)' observations in this dataset.") , linebreak

* Add a histogram to your report
histogram mpg, freq
graph export "mpg.png", replace

putdocx image "mpg.png", linebreak

* Add a table to your report
table1, by(foreign) vars(mpg contn) format("%9.2f") clear

putdocx paragraph
putdocx text ("To make sure the summary statistic is balanced, ")
putdocx text ("the PI asked to always include a table of miles per gallon ")
putdocx text ("by foreign or domestic make. "), linebreak

putdocx table foreign = data(_all), title("MPG by Car Type") halign(center)
putdocx table foreign(1 2, .), bold
putdocx table foreign(., 1), bold


* Save 
putdocx save "putdocx.docx", replace
