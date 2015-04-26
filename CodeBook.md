==================================================================
Getting and Cleaning Data course project
==================================================================
GB
https://github.com/gbenoit75
==================================================================

Code book for the course project

==================================================================
Introduction
==================================================================
The original data are available at the following website:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

The original data are described in the original data set:
- README.txt
- activity_labels.txt
- features.txt
- features_info.txt

==================================================================
Description of the performed analysis
==================================================================

# STEP 0: More information on data analyzed
The data set used provides measures for 6 types of activities:
- walking
- walking upstairs
- walking downstairs
- sitting
- standing
- laying
The measures have been carried out for 30 subjects numbered from 1
to 30.
Values for 561 variables are given. These variables are described in the file "features_info.txt" of the original data set. The physical measures are triaxial (X, Y, Z) acceleration and triaxial angular velocity. Among the 561 variables, many are derived from the physical measures.
A training set and a test set are provided in the orignal data set.

In the following description, the R variables are quoted. For example 'myvar'.
The dimension and the type of the variables are given between parentheses. For example ((2,3, integer) indicates a 2 rows and 3 columns data frame with values of type integer. If a data frame contains more than one type of data (for example integer and numeric), it will be explained in the text.

# STEP 1: Downloading and merging data
1) Download the data to a local directory: The file is called "data.zip"
2) Unzip the data
3) Load the relevant data for the training set:
        - 'subj_test' ((2947,1), integer): The list of subjects of test set
        - 'x_test' ((2947,561), numeric): The measures of the 561 variables of the test set
        - 'y_test' ((2947,1), integer): The activities performed in the test set
4) Load the relevant data for the training set:
        - 'subj_train' ((7352,1), integer): The list of subjects of test set
        - 'x_train' ((7352,561), numeric): The measures of the 561 variables of the test set
        - 'y_train' ((7352,1), integer): The activities performed in the test set
5) Merge in a first data frame called 'df1' all the test data as ('x_test', 'y_test', 'subj_test'). 'df1' dimension is: (2947,563)
6) Merge in a second data frame called 'df2' all the training data as ('x_train', 'y_train', 'subj_train'). 'df2' dimension is: (7352,563)
7) Merge 'df1' and 'df2' with 'df1' as the upper part of the new data frame and 'df2' the lower part of the new data frame (using rbind).
The new data frame called 'dset' has a dimension of (10299,563) with:
        - The first 561 variables of type numeric
        - The 562th and 563th variables of type integer

# STEP 2: Extracts only measurements on the mean and the standard deviation (std)
1) Load the features (name of variables): 'features' ((561,2), (integer, factor))
2) As we want only to extract measurements on the mean and the std, we create two logical vectors:
        - 'index_m' ((561,1), logical): "TRUE" if the variable name in 'dset' contains "mean()", "FALSE" otherwise
        - 'index_std' ((561,1), logical): "TRUE" if the variable name in 'dset' contains "std()", "FALSE" otherwise
3) We construct a new vector called 'indexs' ((561,1), logical). 'indexs' is constructed as follows: if a row value is "TRUE" in 'index_m' or in 'index_std', the corresponding row is "TRUE" in 'indexs'. Otherwise the row value in 'indexs' is "FALSE".
4) We create a last logical vector called 'index': ('indexs', "TRUE", "TRUE"). 'index' is ((563,1), logical). So the vector 'index' has the same number of rows as the data frame 'dset' has columns.
5) Now, we can remove the columns in 'dset' which are not relevant for the analysis: 
        - We add the vector 'index' to 'dset'. 'index' is now the first row of 'dset'
        - We remove all columns of 'dset' for which 'index' is equal to "FALSE" and create a new data frame called 'dset2'
        - We remove the first row of 'dset2'
'dset2' dimension is now (10299,68) with:
        - The first 66 variables of type numeric
        - The 67th and 68th variables of type integer

# STEP 3: Label activities
Simply rename the activities. We replace the integers (between 1 and 6) by a chain of characters:
        - 1 is replaced by "walking"
        - 2 is replaced by "walkingupstairs"
        - 3 is replaced by "walkingdownstairs"
        - 4 is replaced by "sitting"
        - 5 is replaced by "standing"
        - 6 is replaced by "laying"
'dset2' dimension is still (10299,68) but:
        - The first 66 variables are of type numeric
        - The 67th variable is of type character
        - The 68th variable is of type integer

# STEP 4: Label the data set with descriptive variable names
Apply some usual rules on variables name: only lower letters, no underscores or dots, etc.
1) We create a vector called 'vec' ((561,3), (logical, integer, factor)) which is the concatenation of 'indexs' and 'features'.
2) We remove all rows where the logical values are equal to "FALSE". It allows to keep only the variable names of the measurements on the mean and the std ('vec' has now 66 rows).
3) We remove "-", "()" and set all letters to lower case. As additional transformation, we replace "BodyBody" by "Body". It appears in some variables and seems to be an error.
4) We set the names of 'dset2' using the values contained in the third column of 'vec' (for the first 66 columns of 'dset2') and we also add the variable name "activity" and the variable name "subject" for the last two columns.
'dset2' dimension is still (10299,68) with:
        - The first 66 variables are of type numeric
        - The 67th variable is of type character
        - The 68th variable is of type integer
        
# STEP 5: Summarize the data
1) We melt 'dset2' in a new data frame called 'mdata' which has only four variable:
        - "subject"
        - "activity"
        - "variable": it contains the former 66 first variables' names
        - "value": the corresponding value for each combination
'mdata' dimension is ((679734,4), (integer, character, factor, numeric)). 679734 is equal to 10299 rows of 'dset2' * 66 first columns of 'dset2'.
2) We order (ascending) 'mdata' by "subject". So subject n°1 is first and subject n°30 is last.
3) We compute the mean of the different measurements for each activity and each subject. The results are saved in 'tidydata'. 'tidydata' dimension is ((11880,4), (integer, character, factor, numeric))
4) We cast this long table to a wider table. 'tidydata' is now (180,68) with:
        - The first column containing the subject
        - The second column containing the activity
        - The last 66 columns containing the mean on the measurements for each combination of subject and activity.

The variables' name are given below:
"activity": activity of the subject
"subject": subject identification
"tbodyaccmeanx": time body acceleration mean on axis x
"tbodyaccmeany": time body acceleration mean on axis y
"tbodyaccmeanz": time body acceleration mean on axis z
"tbodyaccstdx": time body acceleration standard deviation on axis x
"tbodyaccstdy": time body acceleration standard deviation on axis y
"tbodyaccstdz": time body acceleration standard deviation on axis z
"tgravityaccmeanx": time gravity acceleration mean on axis x
"tgravityaccmeany": time gravity acceleration mean on axis y
"tgravityaccmeanz": time gravity acceleration mean on axis z
"tgravityaccstdx": time gravity acceleration standard deviation on axis x
"tgravityaccstdy": time gravity acceleration standard deviation on axis y
"tgravityaccstdz": time gravity acceleration standard deviation on axis z
"tbodyaccjerkmeanx"
"tbodyaccjerkmeany"
"tbodyaccjerkmeanz"
"tbodyaccjerkstdx"
"tbodyaccjerkstdy"
"tbodyaccjerkstdz"
"tbodygyromeanx"
"tbodygyromeany"
"tbodygyromeanz"
"tbodygyrostdx"
"tbodygyrostdy"
"tbodygyrostdz"
"tbodygyrojerkmeanx"
"tbodygyrojerkmeany"
"tbodygyrojerkmeanz"
"tbodygyrojerkstdx"
"tbodygyrojerkstdy"
"tbodygyrojerkstdz"
"tbodyaccmagmean"
"tbodyaccmagstd"
"tgravityaccmagmean"
"tgravityaccmagstd"
"tbodyaccjerkmagmean"
"tbodyaccjerkmagstd"
"tbodygyromagmean"
"tbodygyromagstd"
"tbodygyrojerkmagmean"
"tbodygyrojerkmagstd"
"fbodyaccmeanx"
"fbodyaccmeany"
"fbodyaccmeanz"
"fbodyaccstdx"
"fbodyaccstdy"
"fbodyaccstdz"
"fbodyaccjerkmeanx"
"fbodyaccjerkmeany"
"fbodyaccjerkmeanz"
"fbodyaccjerkstdx"
"fbodyaccjerkstdy"
"fbodyaccjerkstdz"
"fbodygyromeanx"
"fbodygyromeany"
"fbodygyromeanz"
"fbodygyrostdx"
"fbodygyrostdy"
"fbodygyrostdz"
"fbodyaccmagmean"
"fbodyaccmagstd"
"fbodyaccjerkmagmean"
"fbodyaccjerkmagstd"
"fbodygyromagmean"
"fbodygyromagstd"
"fbodygyrojerkmagmean"
"fbodygyrojerkmagstd"

5) We save locally 'tidydata' to a text file named "tidyData.txt".




